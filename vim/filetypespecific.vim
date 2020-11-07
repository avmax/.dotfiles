
" CSS
        augroup filetype_css
            autocmd!
            autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS noci
            autocmd FileType css set syntax=scss
        augroup END

" SCSS
        au BufRead,BufNewFile *.scss set filetype=scss
        augroup filetype_scss
            autocmd!
            autocmd FileType scss set iskeyword+=-
            " autocmd FileType scss setlocal omnifunc=csscomplete#CompleteCSS noci
            autocmd FileType scss set syntax=scss
        augroup END

" POSTCSS ---
        au BufRead,BufNewFile *.post.css set filetype=postcss
        augroup filetype_postcss
            autocmd!
            autocmd FileType postcss set iskeyword+=-
            autocmd FileType postcss set syntax=scss
            " autocmd FileType postcss setlocal omnifunc=csscomplete#CompleteCSS noci
        augroup END

" HTML
        augroup filetype_html
            autocmd!
            autocmd FileType html setlocal expandtab shiftwidth=2 tabstop=2 softtabstop=2
            autocmd FileType html, EmmetInstall
        augroup END

" Jade
        augroup filetype_jade
            autocmd!
            autocmd BufRead,BufNewFile *.jade set filetype=jade
            autocmd FileType jade setlocal expandtab shiftwidth=2 tabstop=2 softtabstop=2
        augroup END

" Haml
        augroup filetype_haml
            autocmd!
            autocmd FileType haml setlocal expandtab shiftwidth=2 tabstop=2 softtabstop=2
        augroup END

" Yaml
        augroup filetype_yaml
            autocmd!
            autocmd FileType yaml setlocal expandtab shiftwidth=2 tabstop=2 softtabstop=2
        augroup END


" Javascript
        augroup filetype_js
             autocmd!
             autocmd BufRead,BufNewFile *.js set filetype=javascript
             " autocmd FileType javascript setlocal omnifunc=tern#Complete
        augroup END


" Typescript
        augroup filetype_ts
             autocmd!
             autocmd BufRead,BufNewFile .ts set filetype=typescript
             " autocmd FileType typescript setlocal omnifunc=tsuquyomi#complete
             " autocmd FileType typescript setlocal completeopt+=menu,preview
        augroup END


" BEMHTML
        au BufRead,BufNewFile *.bemhtml.js,*.bemtree.js set filetype=bemhtml
        augroup filetype_bemhtml
            autocmd!
            autocmd FileType bemhtml set iskeyword+=-
        augroup END

