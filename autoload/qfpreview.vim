" ==============================================================================
" Preview file with quickfix error in a popup window
" File:         autoload/qfpreview.vim
" Author:       bfrg <https://github.com/bfrg>
" Website:      https://github.com/bfrg/vim-qf-preview
" Last Change:  Nov 1, 2019
" License:      Same as Vim itself (see :h license)
" ==============================================================================

scriptencoding utf-8

let s:save_cpo = &cpoptions
set cpoptions&vim

let s:defaults = #{
        \ height: 15,
        \ scrollup: "\<c-k>",
        \ scrolldown: "\<c-j>",
        \ halfpageup: "\<c-u>",
        \ halfpagedown: "\<c-d>",
        \ fullpageup: "\<c-b>",
        \ fullpagedown: "\<c-f>",
        \ close: 'x',
        \ mapping: v:false
        \ }

function! s:get(key) abort
    let var = get(b:, 'qfpreview', get(g:, 'qfpreview', {}))
    return has_key(var, a:key) ? var[a:key] : s:defaults[a:key]
endfunction

let s:keysmappings = {
        \ 'g': {id -> popup_setoptions(id, #{firstline: 1})},
        \ 'G': {id -> s:bottom(id)},
        \ '+': {id -> s:setheight(id, 1)},
        \ '-': {id -> s:setheight(id, -1)}
        \ }

let s:keysmappings[s:get('scrollup')]       = {id -> s:scroll_line(id, -1)}
let s:keysmappings[s:get('scrolldown')]     = {id -> s:scroll_line(id, 1)}
let s:keysmappings[s:get('halfpageup')]     = {id -> s:scroll_page(id, -0.5)}
let s:keysmappings[s:get('halfpagedown')]   = {id -> s:scroll_page(id, 0.5)}
let s:keysmappings[s:get('fullpageup')]     = {id -> s:scroll_page(id, -1)}
let s:keysmappings[s:get('fullpagedown')]   = {id -> s:scroll_page(id, 1)}
let s:keysmappings[s:get('close')]          = {id -> popup_close(id)}

function! s:scroll_line(winid, step) abort
    let line = popup_getoptions(a:winid).firstline
    if a:step < 0
        let newline = (line + a:step) > 0 ? (line + a:step) : 1
    else
        " TODO use line('$', a:winid) in the future, requires patch-8.1.1967
        call win_execute(a:winid, 'let g:nlines = line("$")')
        let newline = (line + a:step) <= g:nlines ? (line + a:step) : g:nlines
        unlet g:nlines
    endif
    call popup_setoptions(a:winid, #{firstline: newline})
endfunction

function! s:scroll_page(winid, size) abort
    let height = popup_getpos(a:winid).core_height
    let step = float2nr(height*a:size)
    call s:scroll_line(a:winid, step)
endfunction

function! s:bottom(winid) abort
    let height = popup_getpos(a:winid).core_height
    call win_execute(a:winid, 'let g:nlines = line("$")')
    let newline = (g:nlines - height) >= 0 ? (g:nlines - height + 1) : 1
    unlet g:nlines
    call popup_setoptions(a:winid, #{firstline: newline})
endfunction

function! s:setheight(winid, step) abort
    let height = popup_getoptions(a:winid).minheight
    call popup_setoptions(a:winid, #{minheight: height + a:step, maxheight: height + a:step})
endfunction

function! s:popup_filter(winid, key) abort
    if has_key(s:keysmappings, a:key)
        call get(s:keysmappings, a:key)(a:winid)
        return v:true
    endif
    return v:false
endfunction

function! s:space_above(wininfo) abort
    return a:wininfo.winrow - 1
endfunction

function! s:space_below(wininfo) abort
    return &lines - (a:wininfo.winrow + a:wininfo.height - 1) - &cmdheight
endfunction

function! qfpreview#open(idx) abort
    let wininfo = getwininfo(win_getid())[0]
    let qflist = wininfo.loclist ? getloclist(0) : getqflist()
    let qfitem = qflist[a:idx]

    if !qfitem.valid
        return
    endif

    let height = s:get('height')
    let title = printf('%s (%d/%d)', bufname(qfitem.bufnr), a:idx+1, len(qflist))

    " Truncate long titles
    if len(title) > wininfo.width
        let width = wininfo.width - 4
        let title = '…' . title[-width:]
    endif

    if s:space_above(wininfo) > height
        if s:space_above(wininfo) == height + 1
            let height = height - 1
        endif
        let opts = #{
                \ line: wininfo.winrow - 1,
                \ pos: 'botleft'
                \ }
    elseif s:space_below(wininfo) >= height
        let opts = #{
                \ line: wininfo.winrow + wininfo.height,
                \ pos: 'topleft'
                \ }
    elseif s:space_above(wininfo) > 5
        let height = s:space_above(wininfo) - 2
        let opts = #{
                \ line: wininfo.winrow - 1,
                \ pos: 'botleft'
                \ }
    elseif s:space_below(wininfo) > 5
        let height = s:space_below(wininfo) - 2
        let opts = #{
                \ line: wininfo.winrow + wininfo.height,
                \ pos: 'topleft'
                \ }
    elseif s:space_above(wininfo) <= 5 || s:space_below(wininfo) <= 5
        let opts = #{
                \ line: &lines - &cmdheight,
                \ pos: 'botleft'
                \ }
    else
        echohl ErrorMsg
        echomsg 'qfpreview: Not enough space to display popup window.'
        echohl None
        return
    endif

    call extend(opts, #{
            \ col: wininfo.wincol,
            \ minheight: height,
            \ maxheight: height,
            \ minwidth: wininfo.width - 3,
            \ maxwidth: wininfo.width - 3,
            \ firstline: qfitem.lnum < 1 ? 1 : qfitem.lnum,
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

    if has('patch-8.1.1799')
        call extend(opts, #{mapping: s:get('mapping')})
    endif

    hi def link QfPreview Pmenu
    hi def link QfPreviewTitle Pmenu
    hi def link QfPreviewScrollbar PmenuSbar
    hi def link QfPreviewThumb PmenuThumb

    silent let winid = popup_create(qfitem.bufnr, opts)

    if !has('patch-8.1.1919')
        call setwinvar(winid, '&number', 0)
        call setwinvar(winid, '&relativenumber', 0)
        call setwinvar(winid, '&cursorline', 0)
        call setwinvar(winid, '&signcolumn', 'no')
        call setwinvar(winid, '&cursorcolumn', 0)
        call setwinvar(winid, '&foldcolumn', 0)
        call setwinvar(winid, '&colorcolumn', '')
        call setwinvar(winid, '&list', 0)
        call setwinvar(winid, '&scrolloff', 0)
    endif
endfunction

let &cpoptions = s:save_cpo
unlet s:save_cpo
