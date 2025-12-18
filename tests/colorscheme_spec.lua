local Config = require("milkoutside.config")
local Init = require("milkoutside")

before_each(function()
  vim.o.background = "dark"
  vim.cmd.colorscheme("default")
  Config.setup()
  Init.styles = {}
end)

it("did prper init", function()
  assert.same({}, Init.styles)
  assert.same("default", vim.g.colors_name)
  assert.same("dark", vim.o.background)
end)

describe("loading respects vim.o.background", function()
  it("= dark", function()
    vim.o.background = "dark"
    vim.cmd.colorscheme("milkoutside")
    assert.same("dark", vim.o.background)
    assert.same("milkoutside", vim.g.colors_name)
  end)

  it("= light", function()
    vim.o.background = "light"
    vim.cmd.colorscheme("milkoutside")
    assert.same("light", vim.o.background)
    assert.same("milkoutside", vim.g.colors_name)
  end)

  it(" and switches to light", function()
    vim.o.background = "dark"
    vim.cmd.colorscheme("milkoutside")
    vim.o.background = "light"
    assert.same("light", vim.o.background)
    assert.same("milkoutside", vim.g.colors_name)
  end)

  it(" and switches to dark", function()
    vim.o.background = "light"
    vim.cmd.colorscheme("milkoutside")
    vim.o.background = "dark"
    assert.same("dark", vim.o.background)
    assert.same("milkoutside", vim.g.colors_name)
  end)

  it(" and remembers dark", function()
    vim.o.background = "dark"
    vim.cmd.colorscheme("milkoutside")
    vim.o.background = "light"
    vim.o.background = "dark"
    assert.same("dark", vim.o.background)
    assert.same("milkoutside", vim.g.colors_name)
  end)
end)