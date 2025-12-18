local util = require("milkoutside.util")

local M = {}

--- @param colors ColorScheme
function M.generate(colors)
  local tailwindv4 = util.template(
    [[
@theme inline {
  --color-milkoutside-${_style}-bg: oklch(from ${bg} l c h);
  --color-milkoutside-${_style}-bg-dark: oklch(from ${bg_dark} l c h);
  --color-milkoutside-${_style}-bg-dark1: oklch(from ${bg_dark1} l c h);
  --color-milkoutside-${_style}-bg-float: var(--color-milkoutside-${_style}-bg-dark);
  --color-milkoutside-${_style}-bg-highlight: oklch(from ${bg_highlight} l c h);
  --color-milkoutside-${_style}-bg-popup: var(--color-milkoutside-${_style}-bg-dark);
  --color-milkoutside-${_style}-bg-search: var(--color-milkoutside-${_style}-blue0);
  --color-milkoutside-${_style}-bg-sidebar: var(--color-milkoutside-${_style}-bg-dark);
  --color-milkoutside-${_style}-bg-statusline: var(--color-milkoutside-${_style}-bg-dark);
  --color-milkoutside-${_style}-bg-visual: oklch(from ${bg_visual} l c h);
  --color-milkoutside-${_style}-black: oklch(from ${black} l c h);
  --color-milkoutside-${_style}-black-bright: oklch(from ${terminal.black_bright} l c h);
  --color-milkoutside-${_style}-blue: oklch(from ${blue} l c h);
  --color-milkoutside-${_style}-blue-bright: oklch(from ${terminal.blue_bright} l c h);
  --color-milkoutside-${_style}-blue0: oklch(from ${blue0} l c h);
  --color-milkoutside-${_style}-blue1: oklch(from ${blue1} l c h);
  --color-milkoutside-${_style}-blue2: oklch(from ${blue2} l c h);
  --color-milkoutside-${_style}-blue5: oklch(from ${blue5} l c h);
  --color-milkoutside-${_style}-blue6: oklch(from ${blue6} l c h);
  --color-milkoutside-${_style}-blue7: oklch(from ${blue7} l c h);
  --color-milkoutside-${_style}-border: var(--color-milkoutside-${_style}-black);
  --color-milkoutside-${_style}-border-highlight: oklch(from ${border_highlight} l c h);
  --color-milkoutside-${_style}-comment: oklch(from ${comment} l c h);
  --color-milkoutside-${_style}-cyan: oklch(from ${cyan} l c h);
  --color-milkoutside-${_style}-cyan-bright: oklch(from ${terminal.cyan_bright} l c h);
  --color-milkoutside-${_style}-dark3: oklch(from ${dark3} l c h);
  --color-milkoutside-${_style}-dark5: oklch(from ${dark5} l c h);
  --color-milkoutside-${_style}-diff-add: oklch(from ${diff.add} l c h);
  --color-milkoutside-${_style}-diff-change: oklch(from ${diff.change} l c h);
  --color-milkoutside-${_style}-diff-delete: oklch(from ${diff.delete} l c h);
  --color-milkoutside-${_style}-diff-text: var(--color-milkoutside-${_style}-blue7);
  --color-milkoutside-${_style}-error: var(--color-milkoutside-${_style}-red1);
  --color-milkoutside-${_style}-fg: oklch(from ${fg} l c h);
  --color-milkoutside-${_style}-fg-dark: oklch(from ${fg_dark} l c h);
  --color-milkoutside-${_style}-fg-float: var(--color-milkoutside-${_style}-fg);
  --color-milkoutside-${_style}-fg-gutter: oklch(from ${fg_gutter} l c h);
  --color-milkoutside-${_style}-fg-sidebar: var(--color-milkoutside-${_style}-fg-dark);
  --color-milkoutside-${_style}-git-add: oklch(from ${git.add} l c h);
  --color-milkoutside-${_style}-git-change: oklch(from ${git.change} l c h);
  --color-milkoutside-${_style}-git-delete: oklch(from ${git.delete} l c h);
  --color-milkoutside-${_style}-git-ignore: var(--color-milkoutside-${_style}-dark3);
  --color-milkoutside-${_style}-green: oklch(from ${green} l c h);
  --color-milkoutside-${_style}-green-bright: oklch(from ${terminal.green_bright} l c h);
  --color-milkoutside-${_style}-green1: oklch(from ${green1} l c h);
  --color-milkoutside-${_style}-green2: oklch(from ${green2} l c h);
  --color-milkoutside-${_style}-hint: var(--color-milkoutside-${_style}-teal);
  --color-milkoutside-${_style}-info: var(--color-milkoutside-${_style}-blue2);
  --color-milkoutside-${_style}-magenta: oklch(from ${magenta} l c h);
  --color-milkoutside-${_style}-magenta-bright: oklch(from ${terminal.magenta_bright} l c h);
  --color-milkoutside-${_style}-magenta2: oklch(from ${magenta2} l c h);
  --color-milkoutside-${_style}-orange: oklch(from ${orange} l c h);
  --color-milkoutside-${_style}-purple: oklch(from ${purple} l c h);
  --color-milkoutside-${_style}-rainbow1: var(--color-milkoutside-${_style}-blue);
  --color-milkoutside-${_style}-rainbow2: var(--color-milkoutside-${_style}-yellow);
  --color-milkoutside-${_style}-rainbow3: var(--color-milkoutside-${_style}-green);
  --color-milkoutside-${_style}-rainbow4: var(--color-milkoutside-${_style}-teal);
  --color-milkoutside-${_style}-rainbow5: var(--color-milkoutside-${_style}-magenta);
  --color-milkoutside-${_style}-rainbow6: var(--color-milkoutside-${_style}-purple);
  --color-milkoutside-${_style}-rainbow7: var(--color-milkoutside-${_style}-orange);
  --color-milkoutside-${_style}-rainbow8: var(--color-milkoutside-${_style}-red);
  --color-milkoutside-${_style}-red: oklch(from ${red} l c h);
  --color-milkoutside-${_style}-red-bright: oklch(from ${terminal.red_bright} l c h);
  --color-milkoutside-${_style}-red1: oklch(from ${red1} l c h);
  --color-milkoutside-${_style}-teal: oklch(from ${teal} l c h);
  --color-milkoutside-${_style}-todo: var(--color-milkoutside-${_style}-blue);
  --color-milkoutside-${_style}-warning: var(--color-milkoutside-${_style}-yellow);
  --color-milkoutside-${_style}-yellow: oklch(from ${yellow} l c h);
  --color-milkoutside-${_style}-yellow-bright: oklch(from ${terminal.yellow_bright} l c h);
}]],
    colors
  )

  return tailwindv4
end

return M
