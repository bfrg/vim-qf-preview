" ==============================================================================
" Preview file with quickfix error in a popup window
" File:         autoload/qfpreview.vim
" Author:       bfrg <https://github.com/bfrg>
" Website:      https://github.com/bfrg/vim-qf-preview
" Last Change:  Mar 24, 2020
" License:      Same as Vim itself (see :h license)
" ==============================================================================

scriptencoding utf-8

let s:save_cpo = &cpoptions
set cpoptions&vim

hi def link QfPreview           Pmenu
hi def link QfPreviewTitle      Pmenu
hi def link QfPreviewScrollbar  PmenuSbar
hi def link QfPreviewThumb      PmenuThumb

let s:defaults = {
        \ 'height': 15,
        \ 'mouseclick': 'button',
        \ 'scrollbar': v:true,
        \ 'number': v:false,
        \ 'scrollup': "\<c-k>",
        \ 'scrolldown': "\<c-j>",
        \ 'halfpageup': "\<c-u>",
        \ 'halfpagedown': "\<c-d>",
        \ 'fullpageup': "\<c-b>",
        \ 'fullpagedown': "\<c-f>",
        \ 'close': 'x'
        \ }

let s:get = {x -> get(b:, 'qfpreview', get(g:, 'qfpreview', {}))->get(x, s:defaults[x])}

let s:mappings = {
        \ 'g': {id -> popup_setoptions(id, {'firstline': 1})},
        \ 'G': {id -> s:scroll(id, 'G')},
        \ '+': {id -> s:setheight(id, 1)},
        \ '-': {id -> s:setheight(id, -1)}
        \ }

let s:mappings[s:get('scrollup')]     = {id -> s:scroll(id, "\<c-y>")}
let s:mappings[s:get('scrolldown')]   = {id -> s:scroll(id, "\<c-e>")}
let s:mappings[s:get('halfpageup')]   = {id -> s:scroll(id, "\<c-u>")}
let s:mappings[s:get('halfpagedown')] = {id -> s:scroll(id, "\<c-d>")}
let s:mappings[s:get('fullpageup')]   = {id -> s:scroll(id, "\<c-b>")}
let s:mappings[s:get('fullpagedown')] = {id -> s:scroll(id, "\<c-f>")}
let s:mappings[s:get('close')]        = {id -> popup_close(id)}

function! s:scroll(winid, cmd) abort
    call win_execute(a:winid, 'normal! ' .. a:cmd)
    let firstline = popup_getpos(a:winid).firstline
    call popup_setoptions(a:winid, {'firstline': firstline})
endfunction

function! s:setheight(winid, step) abort
    let height = popup_getoptions(a:winid).minheight
    let newheight = height + a:step > 0 ? height + a:step : 1
    call popup_setoptions(a:winid, {'minheight': newheight, 'maxheight': newheight})
endfunction

function! s:popup_filter(winid, key) abort
    if has_key(s:mappings, a:key)
        call get(s:mappings, a:key)(a:winid)
        return v:true
    endif
    return v:false
endfunction

function! qfpreview#open(idx) abort
    let wininfo = getwininfo(win_getid())[0]
    let qflist = wininfo.loclist ? getloclist(0) : getqflist()
    let qfitem = qflist[a:idx]
    let space_above = wininfo.winrow - 1
    let space_below = &lines - (wininfo.winrow + wininfo.height - 1) - &cmdheight

    if !qfitem.valid
        return
    endif

    let height = s:get('height')
    let title = printf('%s (%d/%d)', bufname(qfitem.bufnr), a:idx+1, len(qflist))

    " Truncate long titles
    if len(title) > wininfo.width
        let width = wininfo.width - 4
        let title = '…' .. title[-width:]
    endif

    if space_above > height
        if space_above == height + 1
            let height = height - 1
        endif
        let opts = {
                \ 'line': wininfo.winrow - 1,
                \ 'pos': 'botleft'
                \ }
    elseif space_below >= height
        let opts = {
                \ 'line': wininfo.winrow + wininfo.height,
                \ 'pos': 'topleft'
                \ }
    elseif space_above > 5
        let height = space_above - 2
        let opts = {
                \ 'line': wininfo.winrow - 1,
                \ 'pos': 'botleft'
                \ }
    elseif space_below > 5
        let height = space_below - 2
        let opts = {
                \ 'line': wininfo.winrow + wininfo.height,
                \ 'pos': 'topleft'
                \ }
    elseif space_above <= 5 || space_below <= 5
        let opts = {
                \ 'line': &lines - &cmdheight,
                \ 'pos': 'botleft'
                \ }
    else
        echohl ErrorMsg
        echomsg 'qfpreview: Not enough space to display popup window.'
        echohl None
        return
    endif

    call extend(opts, {
            \ 'col': wininfo.wincol,
            \ 'minheight': height,
            \ 'maxheight': height,
            \ 'minwidth': wininfo.width - 1,
            \ 'maxwidth': wininfo.width - 1,
            \ 'firstline': qfitem.lnum < 1 ? 1 : qfitem.lnum,
            \ 'title': title,
            \ 'close': s:get('mouseclick'),
            \ 'padding': [0,1,1,1],
            \ 'border': [1,0,0,0],
            \ 'borderchars': [' '],
            \ 'moved': 'any',
            \ 'mapping': v:false,
            \ 'filter': funcref('s:popup_filter'),
            \ 'filtermode': 'n',
            \ 'highlight': 'QfPreview',
            \ 'scrollbar': s:get('scrollbar'),
            \ 'borderhighlight': ['QfPreviewTitle'],
            \ 'scrollbarhighlight': 'QfPreviewScrollbar',
            \ 'thumbhighlight': 'QfPreviewThumb'
            \ })

    silent let winid = popup_create(qfitem.bufnr, opts)

    if s:get('number')
        call setwinvar(winid, '&number', 1)
    endif

    return winid
endfunction

let &cpoptions = s:save_cpo
unlet s:save_cpo
