-- nvim/lua/core/debug/inspector.lua
-- Tools for inspecting Neovim state, LSP servers, VPN/proxy, and external API calls with MITM defense

local safe_require = require("core.debug.safe_require")
local logger_ok, logger_mod = safe_require("core.debug.logger")
local fallback = require("core.debug.fallback")
local logger = (logger_ok and logger_mod.get_logger)
  and logger_mod.get_logger("core.debug.inspector")
  or fallback

local api = vim.api
local lsp = vim.lsp or {}
local uv = vim.loop

-- Optionally monitor external API/LLM calls
local api_monitor_ok, api_monitor = safe_require("core.debug.api_monitor")

local M = {}

--- Inspect and log key Neovim state and external context
-- @param namespace string: logger namespace
-- @param context_msg string: optional context description
function M.inspect_state(namespace, context_msg)
  local ctx = context_msg or "Current"

  -- Neovim buffers/windows
  local buffers     = api.nvim_list_bufs()
  local windows     = api.nvim_list_wins()
  local current_buf = api.nvim_get_current_buf()
  local current_win = api.nvim_get_current_win()

  -- Active LSP Clients
  local clients = {}
  if lsp.get_active_clients then
    for _, client in ipairs(lsp.get_active_clients()) do
      table.insert(clients, string.format(
        "%s(root=%s)",
        client.name,
        client.config and client.config.root_dir or "?"
      ))
    end
  end

  -- API Calls Stats per Provider
  local api_stats = api_monitor_ok and api_monitor.get_stats() or {}
  local providers = {"gemini", "anthropic", "grok", "mistral", "deepseek"}
  local apiMsgs = {}
  if api_monitor_ok then
    for _, prov in ipairs(providers) do
      local s = api_stats[prov] or {}
      table.insert(apiMsgs, string.format(
        "%s: total=%d errors=%d avg=%.1fms",
        prov, s.total or 0, s.errors or 0, s.avg_latency or 0.0
      ))
    end
  end

  -- VPN/Proxy Detection
  local proxy_env = {
    http  = os.getenv("HTTP_PROXY")  or os.getenv("http_proxy"),
    https = os.getenv("HTTPS_PROXY") or os.getenv("https_proxy"),
  }
  local proxy_msgs = {}
  if proxy_env.http or proxy_env.https then
    table.insert(proxy_msgs, string.format(
      "Proxy: http=%s https=%s",
      proxy_env.http or "-",
      proxy_env.https or "-"
    ))
  else
    table.insert(proxy_msgs, "Proxy: none detected")
  end
  local vpn = false
  local fh = uv.fs_open("/proc/net/dev", "r", 420) -- 420 decimal == 0o644 read
  if fh then
    local data = uv.fs_read(fh, 65536, 0)
    uv.fs_close(fh)
    for line in data:gmatch("[^]+") do
      if line:match("^%s*(tun%d+|tap%d+):") then vpn = true break end
    end
  end
  table.insert(proxy_msgs, vpn and "VPN: active" or "VPN: not detected")

  -- MITM Defense: Certificate Fingerprint Validation
  local mitm_msgs = {}
  if api_monitor_ok and api_monitor.get_certificates then
    local certs = api_monitor.get_certificates()
    for prov, cert in pairs(certs) do
      local expected = config.api_cert_fingerprints and config.api_cert_fingerprints[prov]
      if expected then
        if cert.fingerprint ~= expected then
          table.insert(mitm_msgs, string.format(
            "MITM ALERT %s: got %s expected %s",
            prov, cert.fingerprint, expected
          ))
        else
          table.insert(mitm_msgs, string.format("%s cert valid", prov))
        end
      else
        table.insert(mitm_msgs, string.format(
          "%s cert not configured", prov
        ))
      end
    end
  end

  -- Compose log message
  local parts = {
    string.format("%s State: Buf=%d Win=%d CurrBuf=%d CurrWin=%d",
      ctx, #buffers, #windows, current_buf, current_win),
    "LSP: " .. table.concat(clients, ", "),
    (api_monitor_ok and ("API: " .. table.concat(apiMsgs, "; "))),
    "Network: " .. table.concat(proxy_msgs, " | "),
    (#mitm_msgs>0) and ("MITM: " .. table.concat(mitm_msgs, "; ")),
  }
  -- Filter nil parts
  local msg = table.concat(vim.tbl_filter(function(v) return v end, parts), "")

  -- Emit
  logger.info(namespace, msg)
end


---
-- Live Dashboard: HTTP server serving JSON state on localhost
-- @param port number: TCP port to serve
function M.start_dashboard(port)
  port = port or 8080
  local server = assert(uv.new_tcp())

  -- TLS/SSL support if configured
  local ssl_ok, ssl = safe_require("ssl")
  local use_tls = ssl_ok and config.tls_cert and config.tls_key
  if use_tls then
    logger.info("core.debug.inspector", "Starting secure dashboard with TLS")
  end

  server:bind("127.0.0.1", port)
  server:listen(128, function(err)
    assert(not err, err)
    local client = server:accept()
    client:settimeout(1000)

    -- Perform TLS handshake if enabled
    if use_tls then
      local params = {
        mode            = "server",
        protocol        = "tlsv1_2",
        key             = config.tls_key,
        certificate     = config.tls_cert,
        options         = "all",
      }
      client = assert(ssl.wrap(client, params))
      assert(client:dohandshake())
    end

    -- Read HTTP/WebSocket request
    local req = client:read_start(function() end)
    (128, function(err)
    assert(not err, err)
    local client = server:accept()
    client:settimeout(1000)
    -- Read HTTP request (headers)
    local req = client:read_start(function() end)

    -- State generator
    local function get_state()
      return vim.fn.json_encode({
        time = os.date("%Y-%m-%dT%H:%M:%SZ"),
        buffers = #api.nvim_list_bufs(),
        windows = #api.nvim_list_wins(),
        current_buffer = api.nvim_get_current_buf(),
        current_window = api.nvim_get_current_win(),
        lsp_clients = vim.tbl_map(function(c) return c.name end, lsp.get_active_clients()),
        api_stats = api_monitor_ok and api_monitor.get_stats() or {},
        network = { proxy = proxy_env, vpn = vpn },
        mitm = mitm_msgs,
      })
    end

    -- Detect WebSocket handshake
    if req and req:match("Upgrade: websocket") then
      -- Compute accept key
      local key = req:match("Sec%-WebSocket%-Key: ([^
]+)")
      if key then
        local digest = vim.fn.system({
          'printf', key .. '258EAFA5-E914-47DA-95CA-C5AB0DC85B11', '|', 'sha1sum', '|', 'awk \'{print $1}\'', '|', 'xxd -r -p', '|', 'base64'
        })
        local resp = table.concat({
          "HTTP/1.1 101 Switching Protocols",
          "Upgrade: websocket",
          "Connection: Upgrade",
          "Sec-WebSocket-Accept: " .. vim.trim(digest),
          "
"
        }, "
")
        client:write(resp)
        -- Periodic send
        local ws_timer = uv.new_timer()
        ws_timer:start(0, config.flush_interval, vim.schedule_wrap(function()
          local frame = get_state()
          local len = #frame
          -- text frame, no mask
          local header = string.char(0x81, len)
          client:write(header .. frame)
        end))
      end
    else
      -- Fallback HTTP response
      local payload = get_state()
      local res = {
        "HTTP/1.1 200 OK",
        "Content-Type: application/json; charset=UTF-8",
        "Content-Length: " .. tostring(#payload),
        "Connection: close", "", payload
      }
      client:write(table.concat(res, "
"))
    end

    client:shutdown()
    client:close()
  end)
  logger.info("core.debug.inspector", "Live dashboard running at http://127.0.0.1:" .. port)
  return server
end)
    -- Generate JSON payload
    local state = {
      time = os.date("%Y-%m-%dT%H:%M:%SZ"),
      buffers = #api.nvim_list_bufs(),
      windows = #api.nvim_list_wins(),
      current_buffer = api.nvim_get_current_buf(),
      current_window = api.nvim_get_current_win(),
      lsp_clients = vim.tbl_map(function(c) return c.name end, lsp.get_active_clients()),
      api_stats = api_monitor_ok and api_monitor.get_stats() or {},
      network = { proxy = proxy_env, vpn = vpn },
      mitm = mitm_msgs,
    }
    local payload = vim.fn.json_encode(state)
    -- Write HTTP response
    local res = {
      "HTTP/1.1 200 OK",
      "Content-Type: application/json; charset=UTF-8",
      "Content-Length: " .. tostring(#payload),
      "Connection: close", "", payload
    }
    client:write(table.concat(res, "
"))
    client:shutdown()
    client:close()
  end)
  logger.info("core.debug.inspector", "Live dashboard running at http://127.0.0.1:" .. port)
  return server
end

return M

