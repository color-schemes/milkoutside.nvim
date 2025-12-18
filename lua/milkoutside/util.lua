local M = {}

M.bg = "#000000"
M.fg = "#ffffff"

local uv = vim.uv or vim.loop

---@param c  string
local function rgb(c)
  c = string.lower(c)
  return { tonumber(c:sub(2, 3), 16), tonumber(c:sub(4, 5), 16), tonumber(c:sub(6, 7), 16) }
end

local me = debug.getinfo(1, "S").source:sub(2)
me = vim.fn.fnamemodify(me, ":h:h")

---@param modname string
function M.mod(modname)
  if package.loaded[modname] then
    return package.loaded[modname]
  end
  local ret = loadfile(me .. "/" .. modname:gsub("%.", "/") .. ".lua")()
  package.loaded[modname] = ret
  return ret
end

---@param foreground string foreground color
---@param background string background color
---@param alpha number|string number between 0 and 1. 0 results in bg, 1 results in fg
function M.blend(foreground, alpha, background)
  alpha = type(alpha) == "string" and (tonumber(alpha, 16) / 0xff) or alpha
  local bg = rgb(background)
  local fg = rgb(foreground)

  local blendChannel = function(i)
    local ret = (alpha * fg[i] + ((1 - alpha) * bg[i]))
    return math.floor(math.min(math.max(0, ret), 255) + 0.5)
  end

  return string.format("#%02x%02x%02x", blendChannel(1), blendChannel(2), blendChannel(3))
end



function M.invert(color)
  local num = tonumber(color, 16)
  return string.format("#%06x", 0xffffff - num)
end

function M.brighten(color, amount)
  color = string.sub(color, 2)
  local hsl = require("milkoutside.hsluv").rgb_to_hsl(color)
  hsl[3] = hsl[3] + amount
  if hsl[3] > 1 then
    hsl[3] = 1
  end
  return require("milkoutside.hsluv").hsl_to_rgb(hsl)
end

function M.darken(color, amount)
  color = string.sub(color, 2)
  local hsl = require("milkoutside.hsluv").rgb_to_hsl(color)
  hsl[3] = hsl[3] - amount
  if hsl[3] < 0 then
    hsl[3] = 0
  end
  return require("milkoutside.hsluv").hsl_to_rgb(hsl)
end

---@param groups table
function M.resolve(groups)
  for name, hl in pairs(groups) do
    for k, v in pairs(hl) do
      hl[k] = type(v) == "string" and resolve(v) or v
    end
  end
  return groups
end

---@param str string
---@param tbl table
function M.template(str, tbl)
  return (str:gsub("($%b+)", function(k)
    return tbl[k] or k
  end))
end

---@param file string
---@param contents string
function M.read(file)
  local fd = assert(io.open(file, "r"))
  return fd:read("*a")
end

---@param file string
---@param contents string
function M.write(file, contents)
  vim.fn.mkdir(vim.fn.fnamemodify(file, ":h"), "p")
  local fd = assert(io.open(file, "w"))
  fd:write(contents)
  fd:close()
end

M.cache = {}

function M.cache.file(key)
  return vim.fn.stdpath("cache") .. "/milkoutside.json"
end

function M.cache.read()
  local ok, ret = pcall(function()
    return vim.json.decode(M.read(M.cache.file())), { luanil = {
      object = true,
      array = true,
    } }
  end)
  return ok and ret or nil
end

---@param data table
function M.cache.write(data)
  local cache_file = M.cache.file()
  local ok, err = pcall(function()
    return M.write(cache_file, vim.json.encode(data))
  end)
  if not ok then
    vim.notify("Cache write failed: " .. err, vim.log.levels.WARN)
  end
end

function M.cache.clear()
  local cache_file = M.cache.file()
  if vim.fn.filereadable(cache_file) then
    os.remove(cache_file)
  end
end

return M
