let s:save_cpo = &cpo
set cpo&vim

if !exists('g:qfreplace_open_cmd')
  let g:qfreplace_open_cmd = 'new'
endif

function! qfreplace#start()
  call s:openReplaceBuffer()
endfunction

function! s:openReplaceBuffer()
  let opened_p = 0
  if exists('b:qfreplace_bufnr')
    let win = bufwinnr(b:qfreplace_bufnr)
    if 0 <= win
      execute win . 'wincmd w'
      let opened_p = !0
    endif
  endif
  if !opened_p
    execute g:qfreplace_open_cmd '[qfreplace]'
    if !exists('b:qfreplace_orig_qflist')  " is the buffer newly created?
      setlocal noswapfile bufhidden=hide buftype=acwrite
      autocmd BufWriteCmd <buffer> nested call s:doReplace()
    endif
    call setbufvar('#', 'qfreplace_bufnr', bufnr('%'))
  endif

  % delete _
  let b:qfreplace_orig_qflist = getqflist()
  for e in b:qfreplace_orig_qflist
    call append(line('$'), e.text)
  endfor
  1 delete _
  setlocal nomodified
endfunction

function! s:doReplace()
  let qf = b:qfreplace_orig_qflist " for easily access
  if line('$') != len(qf)
    throw printf('Illegal edit: line number was changed from %d to %d.',
          \ len(qf), line('$'))
  endif

  setlocal nomodified
  let bufnr = bufnr('%')
  let replace = getline(0, '$')
  let i = 0
  let prev_bufnr = -1
  for e in qf
    execute e.bufnr 'buffer'
    call setline(e.lnum, replace[i])
    if prev_bufnr != e.bufnr
      update
    endif
    let prev_bufnr = e.bufnr
    let i += 1
  endfor
  execute bufnr 'buffer'
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

finish
