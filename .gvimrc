colorscheme torte		" カラースキーム設定
"set background=light		" 背景色の傾向（カラースキームがそれに合わせて色の明暗を変えてくれる）

" IME設定
if has('multi_byte_ime')
	highlight Cursor guifg=NONE guibg=Green
	highlight CursorIM guifg=NONE guibg=Purple
endif

set lines=35		" 画面の高さ
set columns=80		" 画面の幅

" カーソルライン ハイライト設定（gui）
highlight CursorLine gui=underline guifg=NONE guibg=NONE
