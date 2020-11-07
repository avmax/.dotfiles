
" mappings

    let mapleader="\\"



" unmap



" global
    nnoremap <leader>r :source ~/.vimrc <cr>


" navigation in file



"  windows
    " vertical split
    nnoremap <silent> <leader>v :vnew <cr><Esc>

    " navigate
    map <leader>a <C-w>h<C-w>_
    map <leader>d <C-w>l<C-w>_
    map <leader>s <C-w>j<C-w>_
    map <leader>w <C-w>k<C-w>_

    " rotate all windows
    nnoremap <silent> <leader>rt <C-w>r<C-w>h<Esc>
    " rotate all windows backwards
    nnoremap <silent> <leader>rb <C-w>R<C-w>l<Esc>
    " switch with next window
    nnoremap <silent> <leader>st <C-w>x<Esc>
    " switch with prev window
    nnoremap <silent> <leader>sb <C-w>h<C-w>x<C-w>l<Esc>

    " make window wider
    map <silent> <right> :vertical resize +5<cr><Esc>
    " make window narrower
    map <silent> <left> :vertical resize -5<cr><Esc>

    " move window into own tab
    nnoremap <silent> <leader>m :tab split<cr><Esc>



" buffers
    " next buffer
    nnoremap <silent> <leader>q :bprev<cr><Esc>
    " prev buffer
    nnoremap <silent> <leader>e :bnext<cr><Esc>
    " close buffer
    nnoremap <silent> <leader>k :bd!<cr><Esc>



" tabs
    " new tab
    nnoremap <silent> <leader>N :tabnew<Esc>
    " prev tab
    nnoremap <silent> <leader>A :tabp<cr><Esc>
    " next tab
    nnoremap <silent> <leader>D :tabn<cr><Esc>



"  files



" NERDTree
    noremap <BS> :NERDTreeToggle<CR>



" NERDCommenter



" delete
    nnoremap - "_x

    vnoremap - "_d

    nnoremap dl "_dd
    nnoremap dL "_d$
    nnoremap Dl "_d0

    nnoremap dw "_diw
    nnoremap dW "_dt<space>
    nnoremap Dw "_d^

    nnoremap d( "_di(
    nnoremap d[ "_di[
    nnoremap d{ "_di{
    nnoremap d' "_di'
    nnoremap d" "_di"
    nnoremap d< "_di<

    nnoremap D( "_da(
    nnoremap D[ "_da[
    nnoremap D{ "_da{
    nnoremap D' "_da'
    nnoremap D" "_da"
    nnoremap D< "_da<



" cut
    nnoremap _ x

    vnoremap _ d

    nnoremap xl dd
    nnoremap xL d$
    nnoremap Xl d0

    nnoremap xw diw
    nnoremap xW dt<space>
    nnoremap Xw d^

    nnoremap x( di(
    nnoremap x[ di[
    nnoremap x{ di{
    nnoremap x' di'
    nnoremap x" di"
    nnoremap x< di<

    nnoremap X( da(
    nnoremap X[ da[
    nnoremap X{ da{
    nnoremap X' da'
    nnoremap X" da"
    nnoremap X< da<

    nmap XX <Plug>CCP_CutLine
    vmap XX <Plug>CCP_CutText



" yank
    noremap y y
    nnoremap yl yy
    nnoremap yL y$
    nnoremap Yl y0

    nnoremap yw yw
    nnoremap yW yt<space>
    nnoremap Yw y^

    nnoremap y( yi(
    nnoremap y[ yi[
    nnoremap y{ yi{
    nnoremap y' yi'
    nnoremap y" yi"
    nnoremap y< yi<

    nnoremap Y( ya(
    nnoremap Y[ ya[
    nnoremap Y{ ya{
    nnoremap Y' ya'
    nnoremap Y" ya"
    nnoremap Y< ya<

    nmap YY <Plug>CCP_CopyLine
    vmap YY <Plug>CCP_CopyText



" paste
    nmap PP <Plug>CCP_PasteText



" toggle
    nmap t" cs"
    nmap t' cs'
    nmap t( cs(
    nmap t[ cs[
    nmap t{ cs{



" comment



" selections



" search



" programming
    " emmet
    map <silent> <leader>> <C-z>,
