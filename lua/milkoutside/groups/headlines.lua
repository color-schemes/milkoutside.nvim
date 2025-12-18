local Util = require("milkoutside.util")

local M = {}

M.url = "https://github.com/lukas-reineke/headlines.nvim"

---@type milkoutside.HighlightsFn
function M.get(c, opts)
  -- stylua: ignore
  local ret = {
    CodeBlock = { bg = c.bg_dark },
    Headline  = "Headline1",
  }
  local rainbow = { c.red, c.orange, c.yellow, c.green, c.cyan, c.blue, c.magenta }
  for i, color in ipairs(rainbow) do
    ret["Headline" .. i] = { bg = Util.blend_bg(color, 0.05) }
  end
  return ret
end

return M
