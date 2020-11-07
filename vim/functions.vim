" functions 

    function! TRelative()
            set relativenumber!
    endfunc



    function! NoNumber()
            set nonumber
            set norelativenumber
    endfunc
 

    function! Numbers()
    
        set number
        set relativenumber

    endfunc


    function! Hi( name )
        echo "Hello" a:name
    endfunc

    function! MoveToPrevTab()
      "there is only one window
      if tabpagenr('$') == 1 && winnr('$') == 1
        return
      endif
      "preparing new window
      let l:tab_nr = tabpagenr('$')
      let l:cur_buf = bufnr('%')
      if tabpagenr() != 1
        close!
        if l:tab_nr == tabpagenr('$')
          tabprev
        endif
        vs
      else
        close!
        exe "0tabnew"
      endif
      "opening current buffer in new window
      exe "b".l:cur_buf
    endfunc 

    function! MoveToNextTab()
      "there is only one window
      if tabpagenr('$') == 1 && winnr('$') == 1
        return
      endif
      "preparing new window
      let l:tab_nr = tabpagenr('$')
      let l:cur_buf = bufnr('%')
      if tabpagenr() < tab_nr
        close!
        if l:tab_nr == tabpagenr('$')
          tabnext
        endif
        vs
      else
        close!
        tabnew
      endif
      "opening current buffer in new window
      exe "b".l:cur_buf
    endfunc
