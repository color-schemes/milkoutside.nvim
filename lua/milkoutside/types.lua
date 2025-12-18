---@class milkoutside.Highlight: vim.api.keyset.highlight
---@field style? vim.api.keyset.highlight

---@alias milkoutside.Highlights table<string,milkoutside.Highlight|string>

---@alias milkoutside.HighlightsFn fun(colors: ColorScheme, opts:milkoutside.Config):milkoutside.Highlights

---@class milkoutside.Cache
---@field groups milkoutside.Highlights
---@field inputs table
