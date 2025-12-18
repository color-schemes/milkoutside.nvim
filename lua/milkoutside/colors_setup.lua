local M = {}

-- Load consolidated color palette
local colors = require("milkoutside.colors")
local Util = require("milkoutside.util")

---@param opts? milkoutside.Config
function M.setup(opts)
  opts = require("milkoutside.config").extend(opts)

  local palette = vim.deepcopy(colors)

  -- Apply color customizations if provided
  if opts.on_colors then
    opts.on_colors(palette)
  end

  -- Create terminal colors
  palette.terminal = {
    black = palette.terminal_black,
    black_bright = palette.dark3,
    red = palette.red,
    red_bright = palette.red1,
    green = palette.green,
    green_bright = palette.green1,
    yellow = palette.yellow,
    yellow_bright = palette.orange,
    blue = palette.blue,
    blue_bright = palette.blue1,
    magenta = palette.magenta,
    magenta_bright = palette.magenta2,
    cyan = palette.cyan,
    cyan_bright = palette.blue2,
    white = palette.fg_dark,
    white_bright = palette.fg,
  }

  -- Add diff colors
  palette.diff = {
    add = Util.blend(palette.git.add, 0.2, palette.bg),
    change = Util.blend(palette.git.change, 0.2, palette.bg),
    delete = Util.blend(palette.git.delete, 0.2, palette.bg),
    text = palette.blue7,
  }

  -- Add diagnostic colors
  palette.error = palette.red1
  palette.warning = palette.yellow
  palette.info = palette.blue2
  palette.hint = palette.teal
  palette.border = palette.dark3
  palette.border_highlight = palette.red1
  
  -- Add missing UI colors
  palette.bg_popup = palette.bg_dark
  palette.bg_search = palette.bg_highlight
  palette.bg_visual = palette.blue7
  palette.bg_sidebar = palette.bg_dark
  palette.fg_sidebar = palette.fg_dark

  return palette
end

return M