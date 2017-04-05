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
        let l:daemonargs = [s:goviz_bin, '-p', g:goviz_port, 'start']
        if has('nvim')
            let s:goviz_daemon = jobstart(l:daemonargs)
        elseif v:version >= 800
            let s:goviz_daemon = job_start(l:daemonargs)
        else
            call add(l:daemonargs, '&')
            call system(join(l:daemonargs, ' '))
        endif
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

    if has('nvim')
        let l:job = jobstart(l:args)
        call jobsend(l:job, l:content)
        call jobclose(l:job, 'stdin')
    else
        call add(l:args, '&')
        call system(join(l:args, ' '), l:content)
    endif
endfunction

function! s:GovizKill()
    if exists('s:goviz_daemon')
        if has('nvim')
            jobclose(s:goviz_daemon)
        elseif v:version >= 800
            call job_stop(s:goviz_daemon)
        endif
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
