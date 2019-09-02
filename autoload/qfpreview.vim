" ==============================================================================
" Preview file with quickfix error in a popup window
" File:         autoload/qfpreview.vim
" Author:       bfrg <https://github.com/bfrg>
" Website:      https://github.com/bfrg/vim-qf-preview
" Last Change:  Sep 2, 2019
" License:      Same as Vim itself (see :h license)
" ==============================================================================

scriptencoding utf-8

let s:save_cpo = &cpoptions
set cpoptions&vim

function! s:popup_filter(winid, key) abort
    if a:key ==# "\<c-k>"
        let firstline = popup_getoptions(a:winid).firstline
        let newline = (firstline - 2) > 0 ? (firstline - 2) : 1
        call popup_setoptions(a:winid, #{firstline: newline})
        return v:true
    elseif a:key ==# "\<c-j>"
        let firstline = popup_getoptions(a:winid).firstline
        call win_execute(a:winid, 'let g:nlines = line("$")')
        let newline = firstline < g:nlines ? (firstline + 2) : g:nlines
        unlet g:nlines
        call popup_setoptions(a:winid, #{firstline: newline})
        return v:true
        return v:true
    elseif a:key ==# 'x' || a:key ==# "\<esc>"
        call popup_close(a:winid)
        return v:true
    endif
    return v:false
endfunction

function! qfpreview#open(idx) abort
    let wininfo = getwininfo(win_getid())[0]
    let qflist = wininfo.loclist ? getloclist(0) : getqflist()
    let qfitem = qflist[a:idx]
    let title = printf('%s (%d/%d)', bufname(qfitem.bufnr), a:idx+1, len(qflist))

    " Truncate long titles
    if len(title) > wininfo.width
        let width = wininfo.width - 4
        let title = '…' . title[-width:]
    endif

    let freespace = &lines - &cmdheight - wininfo.height - 3
    let height = freespace > 15 ? 15 : freespace

    hi def link QfPreview Pmenu
    hi def link QfPreviewTitle Pmenu
    hi def link QfPreviewScrollbar PmenuSbar
    hi def link QfPreviewThumb PmenuThumb

    silent let winid = popup_create(qfitem.bufnr, #{
            \ line: wininfo.winrow - 1,
            \ col: wininfo.wincol,
            \ pos: 'botleft',
            \ minheight: height,
            \ maxheight: height,
            \ minwidth: wininfo.width - 3,
            \ maxwidth: wininfo.width - 3,
            \ firstline: qfitem.lnum,
            \ title: title,
            \ close: 'button',
            \ padding: [0,1,1,1],
            \ border: [1,0,0,0],
            \ borderchars: [' '],
            \ moved: 'any',
            \ filter: function('s:popup_filter'),
            \ highlight: 'QfPreview',
            \ borderhighlight: ['QfPreviewTitle'],
            \ scrollbarhighlight: 'QfPreviewScrollbar',
            \ thumbhighlight: 'QfPreviewThumb'
            \ })

    if !has('patch-8.1.1919')
        call setwinvar(winid, '&number', 0)
        call setwinvar(winid, '&relativenumber', 0)
        call setwinvar(winid, '&cursorline', 0)
        call setwinvar(winid, '&signcolumn', 'no')
        call setwinvar(winid, '&cursorcolumn', 0)
        call setwinvar(winid, '&foldcolumn' 0)
        call setwinvar(winid, '&colorcolumn', '')
        call setwinvar(winid, '&list', 0)
        call setwinvar(winid, '&scrolloff', 0)
    endif
endfunction

let &cpoptions = s:save_cpo
