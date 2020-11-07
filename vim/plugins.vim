
" plugins
" ---------------------------------

    " required for Vundle
    filetype off

    " set the runtime path to include Vundle and initialize
    set rtp+=~/.vim/bundle/Vundle.vim  
    call vundle#begin()

    " let Vundle manage Vundle, required
    Plugin 'VundleVim/Vundle.vim'

" upgrade vim
        Plugin 'scrooloose/nerdtree'
        Plugin 'scrooloose/nerdcommenter'
        Plugin 'Xuyuanp/nerdtree-git-plugin'
        Plugin 'mileszs/ack.vim'
        Plugin 'tpope/vim-surround'
        Plugin 'NLKNguyen/copy-cut-paste.vim'
        Plugin 'Raimondi/delimitMate'
        Plugin 'bling/vim-bufferline'
        Plugin 'jlanzarotta/bufexplorer'
        Plugin 'schickling/vim-bufonly'
        Plugin 'vim-airline/vim-airline'
        Plugin 'vim-airline/vim-airline-themes'
        Plugin 'editorconfig/editorconfig-vim'
        Plugin 'edkolev/tmuxline.vim'

" git
        Plugin 'airblade/vim-gitgutter'
        Plugin 'tpope/vim-fugitive'

" syntax helpers
        Plugin 'gregsexton/MatchTag'
        Plugin 'elzr/vim-json'
        Plugin 'Chiel92/vim-autoformat'
        Plugin 'JulesWang/css.vim'
        Plugin 'SevInf/vim-bemhtml'
        Plugin 'heavenshell/vim-jsdoc'
        Plugin 'alexlafroscia/postcss-syntax.vim'
        Plugin 'cakebaker/scss-syntax.vim'

" programming
        Plugin 'scrooloose/syntastic'
        " Plugin 'ternjs/tern_for_vim'
        Plugin 'valloric/youcompleteme'
        " [ID] = the extra_menu_info parameter at line 66 in the YouCompleteMe/third_party/ycmd/ycmd/completers/all/identifier_completer.py file.
        Plugin 'mattn/emmet-vim'
        Plugin 'leafgarland/typescript-vim'
        Plugin 'othree/csscomplete.vim'


"  colorshemes
        Plugin 'altercation/vim-colors-solarized'
        Plugin 'flazz/vim-colorschemes'
        Plugin 'ColorSchemeMenuMaker'

    " required
    call vundle#end()

    " requried
    filetype plugin indent on





" plugins settings
" ---------------------------------

" NERDTree
    let NERDTreeShowHidden=1


" NERDTree-git-plugin
    let g:NERDTreeGitStatusIndicatorMapCustom = {
        \ "Modified"  : "✹",
        \ "Staged"    : "✚",
        \ "Untracked" : "✭",
        \ "Renamed"   : "➜",
        \ "Unmerged"  : "═",
        \ "Deleted"   : "✖",
        \ "Dirt"     : "✗",
        \ "Clean"     : "✔︎",
        \ 'Ignored'   : '☒',
        \ "Unknown"   : "?"
    \ }


" NERDCommenter
    " Add spaces after comment delimiters by default
    let g:NERDSpaceDelims = 1
    " Use compac syntax for prettified multi-line comments
    let g:NERDCompactSexyComs = 1
    " Align line-wise comment delimiters flush left instead of following code indentation
    let g:NERDDefaultAlign = 'left'
    " Set a language to use its alternate delimiters by default
    let g:NERDAltDelims_java = 1
    " Add your own custom formats or override the defaults
    let g:NERDCustomDelimiters = { 'c': { 'left': '/**','right': '*/' } }
    " Allow commenting and inverting empty lines (useful when commenting a region)
    let g:NERDCommentEmptyLines = 1
    " Enable trimming of trailing whitespace when uncommenting
    let g:NERDTrimTrailingWhitespace = 1


" airline
    let g:airline_powerline_fonts = 1
    " enable tabline
    let g:airline#extensions#tabline#enabled = 1

    " disable tmuxline
    let g:airline#extensions#tmuxline#enabled = 1

    let g:airline#extensions#tabline#fnamemod = ':t'

    " enable/disable YCM integration >
    let g:airline#extensions#ycm#enabled = 1

    " set error count prefix >
    let g:airline#extensions#ycm#error_symbol = 'E:'

    " set warning count prefix >
    let g:airline#extensions#ycm#warning_symbol = 'W:'

    " disable git hooks
    let g:airline#extensions#hunks#enabled = 0

    let g:airline_section_c = '%{getcwd()}'

    let g:airline_theme='hybrid'


" tmuxline
    let g:tmuxline_separators = {
        \ 'left' : '*',
        \ 'left_alt': '->',
        \ 'right' : '!',
        \ 'right_alt' : '>',
        \ 'space' : '|'}

    let g:tmuxline_theme = 'airline_visual'

    let g:tmuxline_preset = {
          \'a'    : '#S',
          \'b'    : '',
          \'c'    : '',
          \'win'  : ['#I', '#W'],
          \'cwin' : ['#I', '#W'],
          \'x'    : '#(whoami)',
          \'y'    : ['#(date)'],
          \'z'    : '#(~/.tmux/.getPlayingTrack.sh)'}

    let g:tmuxline_theme = {
        \   'bg'   : [ 088, 017],
        \   'a'    : [ 088, 017],
        \   'b'    : [ 088, 017],
        \   'c'    : [ 088, 017],
        \   'win'  : [ 088, 017],
        \   'cwin' : [ 088, 017],
        \   'x'    : [ 088, 017],
        \   'y'    : [ 088, 017],
        \   'z'    : [ 088, 017]
        \ }

" bufferline
    " let g:bufferline_echo = 1
    " let g:bufferline_active_buffer_left = '['
    " let g:bufferline_active_buffer_right = ']'
    " let g:bufferline_modified = '+'
    " let g:bufferline_show_bufnr = 1

" syntastic
    set statusline+=%#warningmsg#
    set statusline+=%{SyntasticStatuslineFlag()}
    set statusline+=%*

    let g:syntastic_always_populate_loc_list = 1
    let g:syntastic_auto_loc_list = 1
    let g:syntastic_check_on_open = 1
    let g:syntastic_check_on_wq = 0

    let g:syntastic_mode_map = {
        \ "mode": "active",
        \ "passive_filetypes": ["html"] }


" emmet
    let g:user_emmet_install_global = 0
    let g:user_emmet_leader_key = '<c-z>'


" copy-cut-paste
    let g:copy_cut_paste_no_mappings = 1

" typescript
    let g:typescript_indent_disable = 1
