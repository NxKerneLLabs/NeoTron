-- lua/core/autocmds.lua v2.0 (KernelLC Edition)


    local ok, lines = pcall(vim.api.nvim_buf_get_lines, args.buf, 0, -1, false)
    if ok then
      local clean_lines = {}
      for _, line in ipairs(lines) do
        table.insert(clean_lines, line:gsub("%s+$", ""))
      end
      pcall(vim.api.nvim_buf_set_lines, args.buf, 0, -1, false, clean_lines)
      debug_log.debug("Espaços removidos em: "..bufname)
    else
      debug_log.error("Falha ao limpar buffer: "..bufname)
    end
  end,
  desc = "Remove trailing spaces (com fallback seguro)"
})

-- Seu autocmd de highlight de yank turbinado
autocmd("TextYankPost", {
  group = KernelLC_Group,
  callback = function()
    local ok, _ = pcall(vim.highlight.on_yank, {
      higroup = "IncSearch",
      timeout = 200,
      on_visual = true,
    })
    if not ok then debug_log.warn("Highlight on yank falhou!") end
  end
})

