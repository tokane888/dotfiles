set autoindent
set encoding=utf-8
set hlsearch
set number
set shiftwidth=2
set smartindent
set tabstop=2

" コピペ時のインデントずれ対策
if &term =~ "xterm"
  let &t_SI .= "\e[?2004h"
  let &t_EI .= "\e[?2004l"
  let &pastetoggle = "\e[201~"

  function XTermPasteBegin(ret)
    set paste
    return a:ret
  endfunction

  inoremap <special> <expr> <Esc>[200~ XTermPasteBegin("")
endif