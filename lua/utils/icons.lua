-- nvim/lua/utils/icons.lua
-- Centralized definition of Nerd Font icons for consistent UI.

local M = {}

-- Ui Elements & General Purpose Icons
M.ui = {
  Telescope = "🔭",
  Search = "",
  Grep = "grep",
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
  Project = "",
  Dashboard = "",
  Settings = "",
  Terminal = "",
  Keyboard = "⌨",
  List = "",
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
  HiddenFile = "",
  Refresh = "",
  Sort = "",
  Tree = "",
  Graph = "📈",
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
  FileCode = "代码",
  FileImage = "",
  FileArchive = "",
  FileAudio = "",
  FileVideo = "",
  FilePdf = "",
  FileSearch = "󰱽",
  Line = "│",
  LineDashed = "┊",
  LineCorner = "└",
  Bug = "",
}

-- Git & Version Control Icons
M.git = {
  Repo = "",
  Branch = "",
  Commit = "󰑐",
  Tag = "",
  Stash = "󰚫",
  GitSignsAdd = "",
  GitSignsChange = "",
  GitSignsDelete = "",
  GitSignsTopDelete = "‾",
  GitSignsChangeDelete = "󰍷",
  Diff = "",
  Merge = "",
  PullRequest = "",
  Issue = "",
  Staged = "✓",
  Unstaged = "✗",
  Untracked = "★",
  Renamed = "➜",
  Deleted = "🗑",
  Ignored = "◌",
  Conflict = "",
}

-- LSP & Diagnostics Icons
M.lsp = {
  LSP = "",
  Definition = M.ui.ArrowRight,
  Declaration = M.ui.ArrowRight,
  References = "󰌷",
  Implementation = "IMP",
  TypeDefinition = "𝙏",
  Hover = M.ui.InfoCircle,
  SignatureHelp = "󰗚",
  CodeAction = M.ui.Lightbulb,
  Rename = M.ui.Pencil,
  Format = "🎨",
  Server = "󰒋",
  Connected = "󰱒",
  Disconnected = "Disconnect",
}

M.diagnostics = {
  Error = "",
  Warn = "",
  Info = M.ui.InfoCircle,
  Hint = M.ui.Lightbulb,
  Debug = M.ui.Bug,
  Trace = "✎",
  Question = M.ui.Question,
  Ok = "✓",
  Location = "📍",
  Bug = M.ui.Bug,
}

-- Miscellaneous & Specific Tool Icons
M.misc = {
  Cmp = "",
  Copilot = "",
  LSP = M.lsp.LSP,
  Bug = M.diagnostics.Bug,
  Help = M.ui.Question,
  Tag = M.git.Tag,
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
  LogPoint = "◆",
  Stopped = "→",
  FrameCurrent = M.ui.ArrowRight,
  Continue = "▶️",
  StepOver = "↷",
  StepInto = "↴",
  StepOut = "↰",
  Stop = "⏹",
  Repl = "💬",
  ToggleUI = M.ui.Dashboard,
  RunLast = "🔁",
  Expanded = "▾",
  Collapsed = "▸",
}

-- Logger
local logger
local logger_ok, logger_mod = pcall(require, "core.debug.logger")
if logger_ok and logger_mod.get_logger then
  logger = logger_mod.get_logger("utils.icons")
  logger.info("utils.icons module loaded successfully.")
else
  vim.notify("utils.icons loaded, but core.debug.logger failed: " .. tostring(logger_mod), vim.log.levels.WARN)
end

return M
