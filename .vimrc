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
Plugin 'alvan/vim-closetag'              " html等の閉じタグ補完
Plugin 'bronson/vim-trailing-whitespace' " :FixWhitespace で全角半角の空白全削除
Plugin 'cohama/lexima.vim'
Plugin 'ctrlpvim/ctrlp.vim'              " ctrl+p でファイル検索。:help ctrlp-mappings
Plugin 'dense-analysis/ale'              " linter
Plugin 'fatih/vim-go'
Plugin 'fisadev/vim-isort'               " pythonのimport文を自動整列／重複import削除
Plugin 'github/copilot.vim'              " :Copilot setupで手動セットアップ必要
Plugin 'godlygeek/tabular'               " plasticboy/vim-markdownが依存
Plugin 'honza/vim-snippets'              " SirVer/ultisnipsが依存
Plugin 'junegunn/fzf'                    " インクリメンタルサーチ
Plugin 'junegunn/fzf.vim'
Plugin 'junegunn/vim-easy-align'         " gaip= => =でindent揃え。 gaip*X" => "(regex)でindent揃え
Plugin 'ludovicchabant/vim-gutentags'    " tags自動生成
Plugin 'mattn/emmet-vim'                 " ctrl+y => , でhtml補完
Plugin 'plasticboy/vim-markdown'         " .mdプレビュー
Plugin 'preservim/tagbar'                " ctagを元に関数一覧表示
Plugin 'psf/black'                       " python formatter
Plugin 'pycqa/autoflake'                 " pythonで不要なimport文等を自動削除
Plugin 'rking/ag.vim'                    " ctrlp.vimの検索高速化
Plugin 'scrooloose/nerdtree'             " ファイル一覧。移動: (ctrl+w,w), 上下左右ウィンドウ移動: (ctrl+[hjkl])
Plugin 'SirVer/ultisnips'                " ctrl+l => snippet一覧。 ctrl+j => snippet決定
Plugin 'suy/vim-ctrlp-commandline'       " ctrl+p => f => f コマンド履歴検索
Plugin 'tacahiroy/ctrlp-funky'           " ctrl+p => f      関数検索
Plugin 'tpope/vim-commentary'            " gcap             comment out paragraph
Plugin 'tpope/vim-fugitive'              " :Git status      ファイル内からgit status
Plugin 'tpope/vim-repeat'
Plugin 'tpope/vim-surround'              " cs' " 'hoge' => " hoge " に括弧を変更
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'vim-ctrlspace/vim-ctrlspace'     " ctrl+spaceでPJ一覧表示
Plugin 'Xuyuanp/nerdtree-git-plugin'
"Plugin 'Yggdroot/indentLine'             " indent可視化。""が表示されないため当面無効化

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on

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
set smartcase                  " 検索パターンに大文字を含んでいたら大文字小文字を区別
set hlsearch

set smartindent                " 改行時に前の行の構文をチェックし、次の行のインデントを増減
set shiftwidth=2               " smartindentで増減するインデントの幅
set expandtab
set tabstop=2
" pythonではpep8にしたがってindentはspace4つに
autocmd FileType python setlocal expandtab shiftwidth=4 softtabstop=4

set list lcs=tab:\|\           " tab可視化
set nolist

set whichwrap=b,s,h,l,<,>,[,],~       " カーソルの左右移動で行末から次の行の行頭へ移動
set cursorline
source $VIMRUNTIME/macros/matchit.vim " %で.shのif => fi, html開始タグから閉じタグ等への移動を可能に
set wildmenu                          " tabキーでコマンドの補完
set history=1000                      " 保存するコマンド履歴の数
set splitright                        " 左右分割時に右側にウィンドウを開く
set noswapfile                        " .swpファイルを生成しない

" vim-ctrlspace/vim-ctrlspace 関連設定(set)
" required
set hidden                            " 保存していないファイルがある場合でも別のファイルopen可能
" option
set showtabline=0                     " defaultのtabを非表示にし、vim-ctrlspaceのものに置き換え

" ファイルを再度開いた際に同じポジションから開始
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

set number
set backspace=indent,eol,start " プラグイン導入後もbackspaceを使用可能に
set t_u7=                      " Vim起動時にReplaceモードになる場合がある問題の対策
set tags=.tags

" ctrl + dでスクロールした際にカーソルを行頭に戻さない
set nostartofline

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
set verbosefile=/tmp/vim_${USER}.log
" normal mode遷移時に英語入力に変更
autocmd InsertLeave * set iminsert=0 imsearch=0
" normal mode遷移時にpaste解除
autocmd InsertLeave * set nopaste
" 折返し無効化
set nowrap

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

" Esc 2回 => ハイライトon/off切り替え
nnoremap <Esc><Esc> :<C-u>set nohlsearch!<CR>
nnoremap j gj
nnoremap k gk
nnoremap <Down> gj
nnoremap <Up> gk
" insert mode時にctrl-sで保存
inoremap <C-s> <Esc>:w<CR>i
nnoremap <C-s> :w<CR>

vnoremap <C-r> "hy:%s/<C-r>h//gc<left><left><left> " virual modeでctrl+r => enterで、1つ1つ確認しながらreplace実行

" Windows Subsystem for Linux で、ヤンクでクリップボードにコピー
if system('uname -a | grep Microsoft') != ''
augroup myYank
    autocmd!
    autocmd TextYankPost * :call system('clip.exe', @")
augroup END
endif

" 行末の空白を自動的に削除
autocmd BufWritePre * :%s/\s\+$//e

" ===========================プラグイン設定===========================

" ctrlpvim/ctrlp.vim
let g:ctrlp_types = ['fil'] "ファイル検索のみ使用
let g:ctrlp_extensions = ['funky', 'commandline'] " CtrlPの拡張として「funky」と「commandline」を使用
" CtrlPCommandLine有効化
command! CtrlPCommandLine call ctrlp#init(ctrlp#commandline#id())
" CtrlPFunky有効化
let g:ctrlp_funky_matchtype = 'path'
" rking/ag.vimとの連携設定
if executable('ag') " agが使える環境の場合
  let g:ctrlp_use_caching=0 " CtrlPのキャッシュを使わない
  " TODO: シンボリックリンクが検索でヒットしないので対応
  " .git repository配下の場合、repository全体が検索される
  let g:ctrlp_user_command='ag %s -i --hidden -g ""' " 「ag」の検索設定
endif

" dense-analysis/ale
let g:ale_fixers={
\   'sh': ['remove_trailing_lines', 'trim_whitespace'],
\   'go': ['remove_trailing_lines', 'trim_whitespace'],
\   'javascript': ['eslint'],
\   'python': ['autoflake', 'black', 'isort'],
\}
let g:ale_linters = {'python': ['flake8']}  " 使用するリンターを選択
let g:ale_fix_on_save=1
let g:ale_sign_error = '❌'
let g:ale_sign_warning = '⚠️'

" fatih/vim-go
let g:go_fmt_command = "goimports"                        " ファイル保存時にimport追加
let g:go_term_enabled = 1                                 " :GoRun結果を別windowで表示
let g:go_term_mode = "silent keepalt rightbelow 15 split" " :GoRun結果を下部windowで表示
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_structs = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1
" :GoRun実行の度に新規ウィンドウを開かず、使いまわす
" TODO: nvim関数を使用せずに実現する方法検討
"function! ReuseVimGoTerm(cmd) abort
"    for w in nvim_list_wins()
"        if "goterm" == nvim_buf_get_option(nvim_win_get_buf(w), 'filetype')
"            call nvim_win_close(w, v:true)
"            break
"        endif
"    endfor
"    execute a:cmd
"endfunction
let g:go_def_reuse_buffer = 1
" TODO: :GoRun実行時に実行結果windowの行番号消す方法調査。:set nonuは元ウィンドウに影響
autocmd FileType go nmap <leader>r :GoRun<Return>         " <leader>+r => :GoRun実行
"autocmd FileType go nmap <leader>r :call ReuseVimGoTerm('GoRun')<Return>

" gutentags_ctags_extra_args
" 自動生成されるパース結果ファイル名をtags => .tagに変更
let g:gutentags_ctags_extra_args=["-f", ".tag"]

" junegunn/vim-easy-align
" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)
" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)

" plasticboy/vim-markdown
let g:vim_markdown_folding_disabled = 1     " 初期状態で畳み込み無効
let g:vim_markdown_new_list_item_indent = 0 "インデント無効化。.vimrcでもきかなくなった。。
"let g:vim_markdown_auto_insert_bullets = 0  " *等の自動挿入無効化

" scrooloose/nerdtree'
nnoremap <silent><C-n> :NERDTreeToggle<CR>
" vim起動時にファイル未指定又はディレクトリを開いた際にNERDTreeを開く
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | exe 'cd '.argv()[0] | endif
" NERDTreeウィンドウだけ開いている場合に閉じる
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
" <leader>+r: NerdTree上で開いているファイルを表示
" ファイルを開いた際に自動的にNerdTree上に当該ファイル表示したいが困難
map <leader>r :NERDTreeFind<cr>

" preservim/tagbar
" F8: 関数一覧表示
nmap <F8> :TagbarToggle<CR>

" SirVer/ultisnips
let g:UltiSnipsExpandTrigger="<c-j>"
let g:UltiSnipsListSnippets="<c-l>"
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<S-tab>"
" :UltiSnipsEdit で登録する独自snippet保存先
let g:UltiSnipsSnippetDirectories=[$HOME.'/.local/dotfiles/vim/UltiSnips']

" vim-airline/vim-airline
let g:airline_theme = 'molokai'

" 80文字以上を許容
let g:ale_yaml_yamllint_options='-d "{extends: relaxed, rules: {line-length: disable}}"'

" vim-ctrlspace/vim-ctrlspace
let g:CtrlSpaceLoadLastWorkspaceOnStart = 1
let g:CtrlSpaceSaveWorkspaceOnSwitch = 1
let g:CtrlSpaceSaveWorkspaceOnExit = 1

