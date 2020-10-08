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
Plugin 'bronson/vim-trailing-whitespace'    " :FixWhitespace で全角半角の空白全削除
Plugin 'cohama/lexima.vim'
Plugin 'ctrlpvim/ctrlp.vim'                 " ctrl+p でファイル検索。:help ctrlp-mappings
Plugin 'fatih/vim-go'
Plugin 'godlygeek/tabular'                  " .mdプレビュー
Plugin 'plasticboy/vim-markdown'            " .mdプレビュー
Plugin 'rking/ag.vim'                       " ctrlp.vimの検索高速化
Plugin 'roxma/nvim-yarp'                    " denite.vimが依存
Plugin 'roxma/vim-hug-neovim-rpc'           " denite.vimが依存
Plugin 'scrooloose/nerdtree'                " ファイル一覧。移動: (ctrl+w,w), 上下左右ウィンドウ移動: (ctrl+[hjkl])
Plugin 'scrooloose/syntastic'               " :Errors でエラー表示。今はjsのみ
Plugin 'Shougo/denite.nvim'
Plugin 'suy/vim-ctrlp-commandline'          " ctrl+p => f => f コマンド履歴検索
Plugin 'tacahiroy/ctrlp-funky'              " ctrl+p => f      関数検索
Plugin 'tpope/vim-fugitive'                 " :Git status      ファイル内からgit status
Plugin 'tpope/vim-surround'                 " cs'"             'hoge' => "hoge"に括弧を変更
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'Xuyuanp/nerdtree-git-plugin'
Plugin 'ycm-core/YouCompleteMe'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
filetype plugin on

" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

set encoding=utf-8             " ファイル読み込み時のエンコード
scriptencoding utf-8           " .vimrcを含むvim script内でマルチバイト文字を使用する場合のエンコード
set fileencoding=utf-8         " ファイル保存時のエンコード
set fileencodings=ucs-boms,utf-8,cp932,euc-jp "ファイル読み込み時の文字コードの自動判別準
set fileformats=unix           " 改行コードCRLFを^Mで表示
set ambiwidth=double           " 文字幅が曖昧な文字の文字幅指定

set incsearch                  " インクリメンタルサーチ。1文字入力毎に検索
set ignorecase                 " 検索パターンに大文字小文字を区別しない
set smartcase                  " 検索パターンに大文字を含んでいたら大文字小文字を区別
set hlsearch
" Esc 2回 => ハイライトon/off切り替え
nnoremap <Esc><Esc> :<C-u>set nohlsearch!<CR>

set autoindent                 " 改行時に前の行のインデントを継続
set smartindent                " 改行時に前の行の構文をチェックし、次の行のインデントを増減
set shiftwidth=2               " smartindentで増減するインデントの幅
set expandtab
set tabstop=2

set whichwrap=b,s,h,l,<,>,[,],~ " カーソルの左右移動で行末から次の行の行頭へ移動
set cursorline
source $VIMRUNTIME/macros/matchit.vim " %で.shのif => fi, html開始タグから閉じタグ等への移動を可能に
set wildmenu                    " tabキーでコマンドの補完
set history=1000                " 保存するコマンド履歴の数

" ファイルを再度開いた際に同じポジションから開始
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

set number
set backspace=indent,eol,start " プラグイン導入後もbackspaceを使用可能に
set t_u7=                      " Vim起動時にReplaceモードになる場合がある問題の対策
set noruler                    " 全角半角文字が混じった行でカーソルを移動すると、日本語表示が重なる問題の対策

syntax on
colorscheme molokai
set t_Co=256
" molokai有効時にctrl+d押下で一部の行の背景色が緑になる問題の対応
set t_ut=""
" gitの差分表示の更新がデフォルトだと4秒後なので100msに変更
set updatetime=100
" ビープ音無効化
set visualbell t_vb=
" /tmp/vim.logに詳細なログ出力
set verbosefile=/tmp/vim.log
" <leader>キー設定
let mapleader=';'
" 日本語入力時にEscで、normal遷移時に英語入力に変更
autocmd InsertLeave * set iminsert=0 imsearch=0

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

" マウス有効化
if has('mouse')
    set mouse=a
    if has('mouse_sgr')
        set ttymouse=sgr
    elseif v:version > 703 || v:version is 703 && has('patch632')
        set ttymouse=sgr
    else
        set ttymouse=xterm2
    endif
endif

" ===========================プラグイン設定===========================

" vim-go
" ファイル保存時にimport追加
let g:go_fmt_command = "goimports"

" YouCompleteMe
" 補完ウィンドウ表示のためにユーザーが入力する必要のある文字数
let g:ycm_min_num_of_chars_for_completion=3
" 関数説明などのpopup自動表示無効化
let g:ycm_auto_hover=""
" \ => d で関数document表示
nmap <leader>d <plug>(YCMHover)
let g:ycm_filetype_blacklist = { 'sh': 1 }

nnoremap <silent><C-e> :NERDTreeToggle<CR>
" vim起動時にファイル未指定又はディレクトリを開いた際にNERDTreeを開く
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | exe 'cd '.argv()[0] | endif

" NERDTreeウィンドウだけ開いている場合に閉じる
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" denite.nvim key mapping
" Define mappings
autocmd FileType denite call s:denite_my_settings()
function! s:denite_my_settings() abort
  nnoremap <silent><buffer><expr> <CR>
  \ denite#do_map('do_action')
  nnoremap <silent><buffer><expr> d
  \ denite#do_map('do_action', 'delete')
  nnoremap <silent><buffer><expr> p
  \ denite#do_map('do_action', 'preview')
  nnoremap <silent><buffer><expr> q
  \ denite#do_map('quit')
  nnoremap <silent><buffer><expr> i
  \ denite#do_map('open_filter_buffer')
  nnoremap <silent><buffer><expr> <Space>
  \ denite#do_map('toggle_select').'j'
endfunction

" lightline.vim
set laststatus=2            " ステータスラインを常に表示
set showmode                " 現在のモードを表示
set showcmd                 " 打ったコマンドをステータスラインの下に表示

" ctrlp.vim
let g:ctrlp_show_hidden = 1 " .(ドット)から始まるファイルも検索対象にする
let g:ctrlp_types = ['fil'] "ファイル検索のみ使用
let g:ctrlp_extensions = ['funky', 'commandline'] " CtrlPの拡張として「funky」と「commandline」を使用
let g:ctrlp_follow_symlinks = 2 " シンボリックリンクを検索対象に含める
" CtrlPCommandLine有効化
command! CtrlPCommandLine call ctrlp#init(ctrlp#commandline#id())
" CtrlPFunky有効化
let g:ctrlp_funky_matchtype = 'path'

" ag.vim
if executable('ag') " agが使える環境の場合
  let g:ctrlp_use_caching=0 " CtrlPのキャッシュを使わない
  " TODO: シンボリックリンクが検索でヒットしないので対応
  let g:ctrlp_user_command='ag %s -i --hidden -g ""' " 「ag」の検索設定
endif

" syntastic
" 構文エラー行に「>>」を表示
let g:syntastic_enable_signs = 1
" 他のVimプラグインと競合するのを防ぐ
let g:syntastic_always_populate_loc_list = 1
" 構文エラーリストを非表示
let g:syntastic_auto_loc_list = 0
" ファイルを開いた時に構文エラーチェックを実行する
let g:syntastic_check_on_open = 1
" 「:wq」で終了する時も構文エラーチェックする
let g:syntastic_check_on_wq = 1
" Javascript用. 構文エラーチェックにESLintを使用
let g:syntastic_javascript_checkers=['eslint']
" Javascript以外は構文エラーチェックをしない
let g:syntastic_mode_map = { 'mode': 'passive',
                           \ 'active_filetypes': ['javascript'],
                           \ 'passive_filetypes': [] }

" vim-airline
let g:airline_theme = 'molokai'
