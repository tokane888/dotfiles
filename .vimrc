set t_u7=                     " Vim起動時にReplaceモードになる場合がある問題の対策
set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

Plugin 'airblade/vim-gitgutter'
Plugin 'bronson/vim-trailing-whitespace'
Plugin 'cohama/lexima.vim'
"Plugin 'fatih/vim-go'
Plugin 'scrooloose/nerdtree'
Plugin 'Xuyuanp/nerdtree-git-plugin'
"Plugin 'ycm-core/YouCompleteMe'
Plugin 'ctrlpvim/ctrlp.vim'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line


set autoindent
set encoding=utf-8
set expandtab
set hlsearch
set number
set shiftwidth=2
set smartindent
set tabstop=2
" プラグイン導入後もbackspaceを使用可能に
set backspace=indent,eol,start
syntax on
colorscheme molokai
set t_Co=256
" molokai有効時にctrl+d押下で一部の行の背景色が緑になる問題の対応
set t_ut=""
" gitの差分表示の更新がデフォルトだと4秒後なので100msに変更
set updatetime=100
" 改行コードCRLFを^Mで表示
set fileformats=unix
" ビープ音無効化
set visualbell t_vb=
" /tmp/vim.logに詳細なログ出力
set verbosefile=/tmp/vim.log
" <leader>キー設定
let mapleader=';'

" vim-go設定
" ファイル保存時にimport追加
let g:go_fmt_command = "goimports"

" YouCompleteMe設定
" 補完ウィンドウ表示のためにユーザーが入力する必要のある文字数
" let g:ycm_min_num_of_chars_for_completion=3
" 関数説明などのpopup自動表示無効化
let g:ycm_auto_hover=""
nmap <leader>d <plug>(YCMHover)

let _curfile=expand("%:r")
if _curfile == 'Makefile'
  set noexpandtab
endif

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

nnoremap <silent><C-e> :NERDTreeToggle<CR>

" vim起動時にファイル未指定又はディレクトリを開いた際にNERDTreeを開く
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | exe 'cd '.argv()[0] | endif

" NERDTreeウィンドウだけ開いている場合に閉じる
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif