command! -nargs=? GovizPreview :call s:GovizPreview(<args>)
command! GovizRefresh :call s:GovizRefresh()
command! GovizKill :call s:GovizKill()

let s:path = fnamemodify(resolve(expand('<sfile>:p')), ':h:h') . '/bin'

if !exists('g:goviz_port')
    let g:goviz_port = 1338
endif

if !exists('s:goviz_bin')
    if has('mac')
        let s:goviz_bin = s:path . '/goviz'
    else
        let s:goviz_bin = s:path . '/goviz_linux'
    endif
endif

function! s:GovizPreview(...)
    if !exists('s:goviz_daemon')
        let s:goviz_daemon = jobstart([s:goviz_bin, '-p', g:goviz_port, 'start'])
    endif

    if !exists('b:previewing')
        let b:previewing = 1
    endif

    let l:id = bufnr('%')
    let l:content = join(getline(1, '$'), "\n")
    let l:args = [s:goviz_bin, '-p', g:goviz_port, "-i", l:id]
    echo
    if a:0 == 0
        call add(l:args, '-l')
    endif
    call add(l:args, 'send')
    let l:job = jobstart(l:args)
    call jobsend(l:job, l:content)
    call jobclose(l:job, 'stdin')
endfunction

function! s:GovizKill()
    if exists('s:goviz_daemon')
        jobclose(s:goviz_daemon)
    else
        let l:job = jobstart([s:goviz_bin, '-p', g:goviz_port, "shutdown"])
        call jobwait(l:job)
    endif
endfunction

function! s:GovizRefresh()
    if exists('b:previewing')
        call s:GovizPreview(1)
    endif
endfunction
