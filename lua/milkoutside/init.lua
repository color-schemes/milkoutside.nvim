local config = require("milkoutside.config")

local M = {}

---@param opts? milkoutside.Config
function M.load(opts)
  opts = require("milkoutside.config").extend(opts)
  return require("milkoutside.theme").setup(opts)
end

M.setup = config.setup

return M
