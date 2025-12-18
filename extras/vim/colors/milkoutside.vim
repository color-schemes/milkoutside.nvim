" =============================================================================
" File:        milkoutside.vim
" Description:   MilkOutside colorscheme for Vim
" Author:       Folke Lemaitre
" Website:      https://github.com/color-schemes/milkoutside.nvim
" License:      MIT
" =============================================================================

hi clear
set background=dark
set termguicolors=true
let g:colors_name="milkoutside"

hi Normal guifg=#e8e8e8 guibg=#040607 ctermfg=254 ctermbg=235
hi NormalNC guifg=#e0e0e0 guibg=#040607 ctermfg=253 ctermbg=235

hi Comment guifg=#595959 ctermfg=245
hi Constant guifg=#63c3dd ctermfg=75
hi Identifier guifg=#e8e8e8 ctermfg=254
hi Statement guifg=#ffad00 ctermfg=214
hi PreProc guifg=#e79cfb ctermfg=177
hi Type guifg=#92cf9c ctermfg=114
hi Special guifg=#ffad00 ctermfg=214
hi Underlined guifg=#63c3dd cterm=underline
hi Ignore guifg=#595959 ctermfg=245
hi Error guifg=#fda1a0 guibg=#3e88ff ctermfg=203 ctermbg=99
hi Todo guifg=#ffad00 guibg=#1a1e2e ctermfg=214 ctermbg=234

hi Cursor guifg=#040607 guibg=#e8e8e8 ctermfg=235 ctermbg=254
hi CursorColumn guibg=#1a1e2e ctermbg=234
hi CursorLine guibg=#1a1e2e cterm=NONE ctermbg=234
hi CursorLineNr guifg=#e8e8e8 guibg=#1a1e2e ctermfg=254 ctermbg=234
hi ColorColumn guibg=#1a1e2e ctermbg=234
hi Conceal guifg=#e79cfb guibg=#040607 ctermfg=177 ctermbg=235

hi Directory guifg=#63c3dd ctermfg=75
hi DiffAdd guifg=#92cf9c guibg=#040607 ctermfg=114 ctermbg=235
hi DiffChange guifg=#ffad00 guibg=#040607 ctermfg=214 ctermbg=235
hi DiffDelete guifg=#fda1a0 guibg=#040607 ctermfg=203 ctermbg=235
hi DiffText guibg=#394b70 ctermbg=237

hi ErrorMsg guifg=#fda1a0 ctermfg=203
hi VertSplit guifg=#303030 guibg=#040607 ctermfg=236 ctermbg=235
hi Folded guifg=#63c3dd guibg=#1a1e2e ctermfg=75 ctermbg=234
hi FoldColumn guifg=#595959 guibg=#040607 ctermfg=245 ctermbg=235
hi SignColumn guifg=#595959 guibg=#040607 ctermfg=245 ctermbg=235
hi IncSearch guifg=#040607 guibg=#ffad00 ctermfg=235 ctermbg=214
hi LineNr guifg=#595959 ctermfg=245
hi MatchParen guifg=#ffad00 guibg=#394b70 ctermfg=214 ctermbg=237
hi ModeMsg guifg=#92cf9c ctermfg=114
hi MoreMsg guifg=#92cf9c ctermfg=114
hi NonText guifg=#595959 ctermfg=245
hi Pmenu guifg=#e8e8e8 guibg=#1a1e2e ctermfg=254 ctermbg=234
hi PmenuSbar guibg=#1a1e2e ctermbg=234
hi PmenuSel guifg=#040607 guibg=#63c3dd ctermfg=235 ctermbg=75
hi Question guifg=#92cf9c ctermfg=114
hi Search guifg=#040607 guibg=#ffad00 ctermfg=235 ctermbg=214
hi SpecialKey guifg=#ffad00 ctermfg=214
hi SpellBad guifg=#fda1a0 guibg=#3e88ff guisp=undercurl ctermfg=203 ctermbg=99
hi SpellCap guifg=#ffad00 guibg=#040607 guisp=undercurl ctermfg=214 ctermbg=235
hi SpellLocal guifg=#ffad00 guibg=#040607 guisp=undercurl ctermfg=214 ctermbg=235
hi SpellRare guifg=#ffad00 guibg=#040607 guisp=undercurl ctermfg=214 ctermbg=235
hi StatusLine guifg=#e8e8e8 guibg=#1a1e2e ctermfg=254 ctermbg=234
hi StatusLineNC guifg=#595959 guibg=#1a1e2e ctermfg=245 ctermbg=234
hi TabLine guifg=#595959 guibg=#1a1e2e ctermfg=245 ctermbg=234
hi TabLineFill guibg=#1a1e2e ctermfg=NONE ctermbg=234
hi TabLineSel guifg=#040607 guibg=#63c3dd ctermfg=235 ctermbg=75
hi Title guifg=#63c3dd ctermfg=75
hi Visual guibg=#394b70 ctermfg=NONE ctermbg=237
hi VisualNOS guibg=#394b70 ctermfg=NONE ctermbg=237
hi WarningMsg guifg=#ffad00 ctermfg=214
hi WildMenu guifg=#e8e8e8 guibg=#1a1e2e ctermfg=254 ctermbg=234

hi link Boolean Constant
hi link Character Constant
hi link Conditional Statement
hi link Debug Special
hi link Define PreProc
hi link Delimiter Special
hi link Exception Statement
hi link Float Number
hi link Function Identifier
hi link Include PreProc
hi link Keyword Statement
hi link Label Statement
hi link Macro PreProc
hi link Number Constant
hi link Operator Statement
hi link PreCondit PreProc
hi link Repeat Statement
hi link SpecialChar Special
hi link SpecialComment Special
hi link Special Special
hi link StorageClass Type
hi link String Constant
hi link Structure Type
hi link Tag Special
hi link Typedef Type