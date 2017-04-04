augroup goviz
    autocmd!
    autocmd BufRead, BufNewFile *.dot,*.gv set filetype=dot
    autocmd BufWritePost <buffer> GovizRefresh
    autocmd VimLeave <buffer> GovizKill
augroup END
