autocmd BufNewFile,BufRead * if search('{{.\+}}', 'nw') | setlocal filetype=html | endif
