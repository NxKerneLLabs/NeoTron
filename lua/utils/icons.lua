-- nvim/lua/utils/icons.lua
-- Centralized definition of Nerd Font icons for consistent UI.

local M = {}

-- Ui Elements & General Purpose Icons
M.ui = {
  Telescope = "🔭",
  Search = "",
  Grep = "grep", -- Consider using Search icon if a specific Grep icon isn't good
  Filter = "",
  Files = "",
  Folder = "",
  FolderOpen = "",
  FolderCog = "",
  FolderSymlink = "",
  FileSymlink = "",
  History = "",
  Clock = "",
  Calendar = "",
  Project = "", -- Using a generic project/folder icon
  Dashboard = "",
  Settings = "",
  Terminal = "",
  Keyboard = "⌨", -- Simpler keyboard icon
  List = "", -- Changed to a more common list icon (scissors often mean cut) -> perhaps  or 
  CheckboxChecked = "",
  CheckboxUnchecked = "",
  ArrowRight = "",
  ArrowLeft = "",
  ArrowDown = "",
  ArrowUp = "",
  ChevronRight = "",
  ChevronLeft = "",
  ChevronDown = "",
  ChevronUp = "",
  BoldChevronRight = "❱",
  BoldChevronLeft = "❰",
  Forward = "",
  Tab = "󰓩",
  Window = "",
  Split = "<y_bin_725>",
  Lock = "",
  Unlock = "",
  Power = "",
  Exit = "",
  Gear = "⚙",
  Tools = "",
  Wrench = "",
  Save = "",
  Edit = "",
  View = "",
  HiddenFile = "", -- Check if this icon renders well, might need an alternative like ".𝒇"
  Refresh = "",
  Sort = "",
  Tree = "",
  Graph = "📈", -- Simpler graph icon
  Table = "",
  Column = "",
  BoldClose = "",
  Close = "",
  Ellipsis = "…",
  Plus = "",
  Minus = "",
  Question = "",
  InfoCircle = "",
  Lightbulb = "",
  Comment = "",
  Code = "",
  Link = "",
  Plugin = "",
  Package = "",
  Rocket = "",
  Fire = "",
  Notification = "",
  Audio = "",
  Pencil = "",
  FileCode = "代码", -- Example: File with 'code' text if specific icon is not good
  FileImage = "",
  FileArchive = "",
  FileAudio = "",
  FileVideo = "",
  FilePdf = "",
  FileSearch = "󰱽",
  Line = "│",
  LineDashed = "┊",
  LineCorner = "└",
  Bug = "", -- Moved Bug here as it's used by M.diagnostics later
}

-- Git & Version Control Icons
M.git = {
  Repo = "",
  Branch = "",
  Commit = "󰑐", -- Different commit icon
  Tag = "",
  Stash = "󰚫",
  GitSignsAdd = "",
  GitSignsChange = "",
  GitSignsDelete = "",
  GitSignsTopDelete = "‾", -- This might be too subtle; consider alternative
  GitSignsChangeDelete = "󰍷",
  Diff = "",
  Merge = "",
  PullRequest = "",
  Issue = "",
  Staged = "✓",
  Unstaged = "✗",
  Untracked = "★", -- Or "?"
  Renamed = "➜",
  Deleted = "🗑",
  Ignored = "◌",
  Conflict = "",
}

-- LSP & Diagnostics Icons
-- Define M.lsp once
M.lsp = {
  LSP = "",
  Definition = M.ui.ArrowRight, -- Re-use from ui
  Declaration = M.ui.ArrowRight, -- Re-use from ui
  References = "󰌷",
  Implementation = "IMP", -- Keep as text or find suitable icon
  TypeDefinition = "𝙏", -- Keep as text or find suitable icon
  Hover = M.ui.InfoCircle, -- Re-use from ui
  SignatureHelp = "󰗚",
  CodeAction = M.ui.Lightbulb, -- Re-use from ui
  Rename = M.ui.Pencil, -- Re-use from ui
  Format = "🎨",
  Server = "󰒋",
  Connected = "󰱒",
  Disconnected = "Disconnect", -- Text for disconnected
}

-- Define M.diagnostics once
M.diagnostics = {
  Error = "",
  Warn = "",
  Info = M.ui.InfoCircle, -- Re-use from ui
  Hint = M.ui.Lightbulb, -- Re-use from ui
  Debug = M.ui.Bug, -- Use the one defined in M.ui
  Trace = "✎",
  Question = M.ui.Question,
  Ok = "✓",
  Location = "📍", -- Location pin
  Bug = M.ui.Bug, -- Ensure this is consistent
}


-- Miscellaneous & Specific Tool Icons
M.misc = {
  Cmp = "",
  Copilot = "",
  LSP = M.lsp.LSP, -- Re-use from lsp
  Bug = M.diagnostics.Bug, -- Re-use from diagnostics
  Help = M.ui.Question,
  Tag = M.git.Tag, -- Re-use from git
  Tree = M.ui.Tree,
  List = M.ui.List,
  Package = M.ui.Package,
  ManPage = "",
  Scroll = "",
  Clipboard = "",
  Calendar = M.ui.Calendar,
  Fire = M.ui.Fire,
  Rocket = M.ui.Rocket,
  Key = "",
  Database = "",
  Network = "󰛵",
  CPU = "",
  Memory = "",
  Disk = "",
  Cloud = "☁",
  Mail = "",
  Message = "",
  User = "",
  Group = "",
  Home = "",
  Lock = M.ui.Lock,
  Unlock = M.ui.Unlock,
  Book = "",
}

-- Filetype Icons
M.filetypes = {
  Default = M.ui.Files,
  Lua = "", Python = "", JavaScript = "", TypeScript = "",
  JSX = "", TSX = "󰛦", HTML = "", CSS = "", SCSS = "󰘐",
  JSON = "", YAML = "yaml", Markdown = "", Text = "",
  Shell = "", Git = M.git.Repo, Docker = "󰡨", SQL = M.misc.Database,
  Rust = "", Go = "", Java = "", C = "", Cpp = "",
  CSharp = "󰌛", Ruby = "", PHP = "", Perl = "", Swift = "",
  Kotlin = "", Zig = "", Nix = "", Terraform = "󱁢",
  TOML = "𝑡𝑜𝑚𝑙", Makefile = M.ui.Gear, CMake = M.ui.Gear,
  PackageJson = M.ui.Package, Image = M.ui.FileImage, Archive = M.ui.FileArchive,
  Audio = M.ui.FileAudio, Video = M.ui.FileVideo, PDF = M.ui.FilePdf,
}

-- Icons for LSP/TreeSitter kinds
M.kinds = {
  Text = "", Method = "ƒ", Function = "", Constructor = "",
  Field = "󰽏", Variable = "󰫧", Class = "", Interface = "",
  Module = "", Property = "", Unit = "󰑭", Value = "󰎠",
  Enum = "", Keyword = "󰌋", Snippet = "", Color = "󰏘",
  File = M.ui.Files, Reference = M.lsp.References, Folder = M.ui.Folder,
  EnumMember = "", Constant = "", Struct = "", Event = "",
  Operator = "󰆕", TypeParameter = "󰊄", Package = M.ui.Package,
  Namespace = "󰌗", Array = "[]", Boolean = "Boolean", Key = M.misc.Key,
  Null = "NULL", Number = "#", Object = "{}", String = "𝓐",
  TypeAlias = "󰊄", Unknown = M.ui.Question,
}

-- DAP specific icons
M.dap = {
  Breakpoint = "●",
  BreakpointCondition = "◆",
  LogPoint = "◆", -- Consider "L●" or similar if distinct icon needed
  Stopped = "→",
  FrameCurrent = M.ui.ArrowRight, -- Current frame indicator
  Continue = "▶️",
  StepOver = "↷",
  StepInto = "↴",
  StepOut = "↰",
  Stop = "⏹",
  Repl = "💬",
  ToggleUI = M.ui.Dashboard, -- Use a generic UI/panel icon
  RunLast = "🔁",
  Expanded = "▾",
  Collapsed = "▸",
}

-- Log at the very end, after M is fully populated.
-- This pcall is fine, but if core.debug itself has issues, this might not show.
local logger
local core_debug_ok, core_debug_module = pcall(require, "core.debug.logger")
if core_debug_ok and core_debug_module and core_debug_module.info then
  core_debug_module.info("utils.icons", "utils.icons module loaded successfully.")
elseif core_debug_ok and core_debug_module and type(core_debug_module) == "table" and not core_debug_module.info then
   -- This case means core.debug loaded but doesn't have an 'info' function directly.
   -- It might have a get_logger function.
   if core_debug_module.get_logger then
       local logger = core_debug_module.get_logger("utils.icons")
       logger.info("utils.icons module loaded successfully (via get_logger).")
   else
       vim.notify("utils.icons loaded, but core.debug.info or core.debug.get_logger not found.", vim.log.levels.WARN)
   end
else
  vim.notify("utils.icons loaded, but core.debug could not be loaded for logging. Error: " .. tostring(core_debug_module), vim.log.levels.WARN)
end

return M

