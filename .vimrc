set encoding=utf-8
scriptencoding utf-8

"------------------------------------------------
" MyAutoCmdグループの初期化処理
"------------------------------------------------
augroup MyAutoCmd
  autocmd!
augroup END

"------------------------------------------------
" プラグインマネージャ設定
"------------------------------------------------
if !&compatible
    set nocompatible
endif

" dein settings {{{
" dein自体の自動インストール
let s:cache_home = empty($XDG_CACHE_HOME) ? expand('~/.cache') : $XDG_CACHE_HOME
let s:dein_dir = s:cache_home . '/dein'
let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'
if !isdirectory(s:dein_repo_dir)
    call system('git clone https://github.com/Shougo/dein.vim ' .shellescape(s:dein_repo_dir))
endif
let &runtimepath = s:dein_repo_dir . ",". &runtimepath
" プラグイン読み込み＆キャッシュ作成
" dotfileに移すためdein.tomlの配置を変更
"let s:toml_file = fnamemodify(expand('<sfile>'), ':h').'/dein.toml'
if dein#load_state(s:dein_dir)
    call dein#begin(s:dein_dir)

    let g:rc_dir = expand('~/dotfiles/dein')
    let s:toml = g:rc_dir . '/dein.toml'
" まだlazy_tomlを使用していないのでコメントアウト
"    let s:lazy_toml = g:rc_dir . 'dein_lazy.toml'

    " TOMLファイルにpluginを記述
    call dein#load_toml(s:toml,      {'lazy': 0})
" まだlazy_tomlを使用していないのでコメントアウト
"    call dein#load_toml(s:lazy_toml, {'lazy': 1})
    call dein#end()
    call dein#save_state()
endif

" 不足プラグインの自動インストール
if has('vim_starting') && dein#check_install()
    call dein#install()
endif

" }}}

"------------------------------------------------
" im_control.vim setting
"------------------------------------------------
" fcitx
" 「日本語入力固定モード」の動作設定
let IM_CtrlMode = 6
" 「日本語入力固定モード」切り替えキー
inoremap <silent> <C-o> <C-o>=IMState('FixMode')<CR>

" <ESC>押下後のIM切替開始までの反応が遅い場合はttimeoutlenを短く設定
set timeout timeoutlen=3000 ttimeoutlen=100

"------------------------------------------------
" カラースキーム系
"------------------------------------------------
set t_Co=256
syntax on                           " シンタックスカラーリングオン

"------------------------------------------------
" 文字コード系
"------------------------------------------------
set fileencoding=utf-8              " 保存時の文字コード
set fileencodings=ucs-boms,utf-8,euc-jp,cp932   " 読み込み時の文字コード
set fileformats=unix,dos,mac        " 改行コードの自動判別。左側が優先
set ambiwidth=double                " □や○文字が崩れる問題対応

"------------------------------------------------
" ステータスライン
"------------------------------------------------
set laststatus=2                    " ステータスラインを表示
"set statusline+=%{IMStatus('[日本語固定]')}
" 挿入モード時、ステータスラインの色を変更
let g:hi_insert = 'highlight StatusLine guifg=darkblue guibg=darkyellow gui=none ctermfg=blue ctermbg=yellow cterm=none'

if has('syntax')
    augroup InsertHook
    autocmd!
        autocmd InsertEnter * call s:StatusLine('Enter')
        autocmd InsertLeave * call s:StatusLine('Leave')
    augroup END
endif

let s:slhlcmd = ''
function! s:StatusLine(mode)
    if a:mode == 'Enter'
        silent! let s:slhlcmd = 'highlight ' . s:GetHighlight('StatusLine')
        silent exec g:hi_insert
    else
        highlight clear StatusLine
        silent exec s:slhlcmd
    endif
endfunction

function! s:GetHighlight(hi)
    redir => hl
    exec 'highlight '.a:hi
    redir END
    let hl = substitute(hl, '[\r\n]', '', 'g')
    let hl = substitute(hl, 'xxx', '', '')
    return hl
endfunction

"------------------------------------------------
" 検索系
"------------------------------------------------
set wrapscan                        " 最後まで検索したら先頭へ戻る
set ignorecase                      " 大文字小文字を区別しない
set smartcase                       " 検索文字に大文字がある場合は大文字小文字を区別
set incsearch                       " インクリメンタルサーチ
set hlsearch                        " 検索マッチテキストをハイライト

" バックスラッシュやクエスチョンを状況に合わせ自動的にエスケープ
cnoremap <expr> / getcmdtype() == '/' ? '\/' : '/'
cnoremap <expr> ? getcmdtype() == '?' ? '\?' : '?'

"------------------------------------------------
" カーソル系
"------------------------------------------------
"set virtualedit=all                 " カーソルを文字が存在しない部分でも動けるようにする
set cursorline                      " カーソルライン有効化
" カーソルライン ハイライト設定（color terminal）
highlight CursorLine cterm=underline ctermfg=NONE ctermbg=NONE
set showmatch                       " 対応する括弧などをハイライト表示する
set matchtime=3                     " 対応括弧のハイライト表示を3秒にする
set matchpairs& matchpairs+=<:>     " 対応括弧に'<'と'>'のペアを追加
source $VIMRUNTIME/macros/matchit.vim   " Vimの「%」を拡張
set backspace=indent,eol,start      " バックスペースで特殊記号も削除可能に
set whichwrap+=b,s,h,l,<,>,[,]       " カーソルを行頭行末で止まらないようにする
"------------------------------------------------
" 編集系
"------------------------------------------------
set autoread                        " 更新時自動再読み込み
set shiftround                      " '<'や'>'でインデントする際に'shiftwidth'の倍数に丸める
set infercase                       " 補完時に大文字小文字を区別しない
set hidden                          " バッファを閉じる代わりに隠す（Undo履歴を残すため）
set switchbuf=useopen               " 新しく開く代わりにすでに開いてあるバッファを開く
set nowritebackup                   " バックアップ記載しない
set nobackup                        " バックアップをとらない
set noswapfile                      " SWAPファイルを作らない

" クリップボードをデフォルトのレジスタとして指定。後にYankRingを使うので
" 'unnamedplus'が存在しているかどうかで設定を分ける必要がある
if has('unnamedplus')
    set clipboard& clipboard+=unnamedplus,unnamed
else
    set clipboard& clipboard+=unnamed
endif

"------------------------------------------------
" インデント
"------------------------------------------------
set expandtab                       " タブ入力を複数の空白入力に置き換える
set tabstop=4                       " 画面上でタブ文字が占める幅
set softtabstop=4                   " 連続した空白に対してタブキーやバックスペースキーでカーソルが動く幅
set autoindent                      " 改行時に前の行のインデントを継続する
set smartindent                     " 改行時に前の行の構文をチェックし次の行のインデントを増減する
set shiftwidth=4                    " smartindentで増減する幅
retab

"------------------------------------------------
" 表示系
"------------------------------------------------
set list                            " 不可視文字の可視化
set number                          " 行番号の表示
set ruler                           " カーソル位置表示
set nowrap                          " 画面幅で折り返さない
set textwidth=0                     " 自動的に改行が入るのを無効化
set colorcolumn=80                  " その代わり80文字目にラインを入れる

" スクリーンベルを無効化
set t_vb=
set novisualbell

" デフォルト不可視文字をUnicodeにする
set listchars=tab:^\ ,trail:-,extends:>,precedes:<,nbsp:%,eol:↲

" 全角スペース可視化
function! ZenkakuSpace()
    highlight ZenkakuSpace cterm=underline ctermfg=darkgrey gui=underline guifg=darkgrey
endfunction

if has('syntax')
    augroup ZenkakuSpace
        autocmd!
        autocmd ColorScheme * call ZenkakuSpace()
        autocmd VimEnter,WinEnter * match ZenkakuSpace /<81>@/
    augroup END
    call ZenkakuSpace()
endif

"------------------------------------------------
" コマンド補完
"------------------------------------------------
set wildmenu                        " コマンドモートの補完
set history=5000                    " 保存するコマンド履歴

"------------------------------------------------
" マクロ、キー設定
"------------------------------------------------
imap <silent> jj <Esc>
imap <silent> っｊ <Esc>
inoremap <c-o> <END>
inoremap <c-a> <HOME>
inoremap <c-h> <LEFT>
inoremap <c-j> <DOWN>
inoremap <c-k> <UP>
inoremap <c-l> <Right>

 " ESCを2回押すことでハイライトを消す
nnoremap <silent><Esc><Esc> :<C-u>set nohlsearch!<CR>

" カーソルの下の単語を * で検索
vnoremap <silent> * "vy/\V<C-r>=substitute(escape(@v, '\/'), "\n",'\\n', 'g')<CR><CR>

" 検索後にジャンプした際に検索単語を画面中央に持ってくる
nnoremap n nzz
nnoremap N Nzz
nnoremap * *zz
nnoremap # #zz
nnoremap g* g*zz
nnoremap g# g#zz

" j,kによる移動をおりかえされたテキストでも自然に振る舞うように変更
nnoremap j gj
nnoremap k gk
nnoremap <down> gj
nnoremap <up> gk
 " vを2回で行末まで選択
vnoremap v $h

" TABにて対応ペアにジャンプ
nnoremap <Tab> %
vnoremap <Tab> %

" Ctrl + hjklでウィンドウ間を移動
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Shift + 矢印でウィンドウサイズを変更
nnoremap <S-Left> <C-w><<CR>
nnoremap <S-Right> <C-w>><CR>
nnoremap <S-Up> <C-w>-<CR>
nnoremap <S-Down> <C-w>+<CR>


" T + ? で各種設定をトグル
nnoremap [toggle] <Nop>
nmap T [toggle]
nnoremap <silent> [toggle]s :setl spell!<CR>:setl spell?<CR>
nnoremap <silent> [toggle]l :setl list!<CR>:setl list?<CR>
nnoremap <silent> [toggle]t :setl expandtab!<CR>:setl expandtab?<CR>
nnoremap <silent> [toggle]w :setl wrap!<CR>:setl wrap?<CR>

" ma&ke, grepなどのコマンド後に自動的にQuickFixを開く
autocmd MyAutoCmd QuickfixCmdPost make,grep,grepadd,vimgrep copen

" QuickFixおよびHelpではqでバッファを閉じる
autocmd MyAutoCmd FileType help,qf nnoremap <buffer> q <C-w>c

" w!! でスーパーユーザーとして保存
cmap w!! w !sudo tee > /dev/null %

" :e などでファイルを開く際にフォルダが存在しない場合は自動生成
function! s:mkdir(dir, force)
    if !isdirectory(a:dir) && (a:force ||
        \ input(printf('"%s" does not exist. Create? [y/N]', a:dir)) =~? '^y\%[es]$')
        call  mkdir(iconv(a:dir, &encoding, &termencoding), 'p')
    endif
endfunction
autocmd MyAutoCmd BufWritePre * call s:mkdir(expand('<afile>:p:h'), v:cmdbang)

" vim 起動時のみカレントディレクトリを開いたファイルの親ディレクトリに指定
autocmd MyAutoCmd VimEnter * call s:ChangeCurrentDir('', '')
function! s:ChangeCurrentDir(directory, bang)
    if a:directory == ''
        lcd %:p:h
    else
        execute 'lcd' . a:directory
    endif

    if a:bang == ''
        pwd
    endif
endfunction

" ~/.vimrc.localが存在する場合のみ設定を読み込む
let s:local_vimrc = expand('~/.vimrc.local')
if filereadable(s:local_vimrc)
    execute 'source ' . s:local_vimrc
endif

