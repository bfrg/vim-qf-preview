" ==============================================================================
" Preview file with quickfix error in a popup window
" File:         autoload/qfpreview.vim
" Author:       bfrg <https://github.com/bfrg>
" Website:      https://github.com/bfrg/vim-qf-preview
" Last Change:  Aug 6, 2020
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
        \ 'number': v:false,
        \ 'offset': 0,
        \ 'sign': {},
        \ 'matchcolumn': v:false,
        \ 'scrollup': "\<c-k>",
        \ 'scrolldown': "\<c-j>",
        \ 'halfpageup': '',
        \ 'halfpagedown': '',
        \ 'fullpageup': '',
        \ 'fullpagedown': '',
        \ 'top': "\<s-home>",
        \ 'bottom': "\<s-end>",
        \ 'reset': 'r',
        \ 'close': 'q',
        \ 'next': '',
        \ 'previous': ''
        \ }

let s:get = {x -> get(b:, 'qfpreview', get(g:, 'qfpreview', {}))->get(x, s:defaults[x])}

" winid of popup window
let s:winid = 0

" Save quickfix list while popup is open for cycling to next or previous item
let s:qflist = []

function s:error(msg)
    echohl ErrorMsg | echomsg a:msg | echohl None
endfunction

function s:reset(winid, line) abort
    call popup_setoptions(a:winid, {'firstline': a:line})
    call popup_setoptions(a:winid, {'firstline': 0})
    if !empty(s:get('sign')->get('text', '')) && !has('patch-8.2.1303')
        call setwinvar(a:winid, '&signcolumn', 'number')
    endif
endfunction

function s:cycle(winid, step) abort
    let cur_pos = getpos('.')
    let new_lnum = line('.') + a:step > line('$')
            \ ? line('$')
            \ : line('.') + a:step < 1 ? 1 : line('.') + a:step

    while !s:qflist[new_lnum - 1].valid
            \ && s:qflist[new_lnum - 1].bufnr < 1
            \ && new_lnum > 0
            \ && new_lnum < line('$')
        let new_lnum += a:step
    endwhile

    if new_lnum == cur_pos[1] || !s:qflist[new_lnum - 1].valid || s:qflist[new_lnum - 1].bufnr < 1
        return
    endif

    call popup_close(a:winid)
    let cur_pos[1] = new_lnum
    call setpos('.', cur_pos)
    call qfpreview#open(line('.') - 1)
endfunction

function s:popup_filter(line, winid, key) abort
    let mappings = {}
    let mappings[s:get('close')]        = {id -> popup_close(id)}
    let mappings[s:get('top')]          = {id -> win_execute(id, 'normal! gg')}
    let mappings[s:get('bottom')]       = {id -> win_execute(id, 'normal! G')}
    let mappings[s:get('scrollup')]     = {id -> win_execute(id, "normal! \<c-y>")}
    let mappings[s:get('scrolldown')]   = {id -> win_execute(id, "normal! \<c-e>")}
    let mappings[s:get('halfpageup')]   = {id -> win_execute(id, "normal! \<c-u>")}
    let mappings[s:get('halfpagedown')] = {id -> win_execute(id, "normal! \<c-d>")}
    let mappings[s:get('fullpageup')]   = {id -> win_execute(id, "normal! \<c-b>")}
    let mappings[s:get('fullpagedown')] = {id -> win_execute(id, "normal! \<c-f>")}
    let mappings[s:get('reset')]        = {id -> s:reset(id, a:line)}
    let mappings[s:get('next')]         = {id -> s:cycle(id,  1)}
    let mappings[s:get('previous')]     = {id -> s:cycle(id, -1)}
    call filter(mappings, '!empty(v:key)')

    if has_key(mappings, a:key)
        call get(mappings, a:key)(a:winid)
        return v:true
    endif

    return v:false
endfunction

function s:popup_cb(winid, result) abort
    let s:qflist = []
    if !empty(s:get('sign'))
        call sign_unplace('PopUpQfPreview')
        if !empty(sign_getdefined('QfErrorLine'))
            call sign_undefine('QfErrorLine')
        endif
    endif
endfunction

function qfpreview#open(idx) abort
    let wininfo = getwininfo(win_getid())[0]

    if empty(s:qflist)
        let s:qflist = wininfo.loclist ? getloclist(0) : getqflist()
        if empty(s:qflist)
            return
        endif
    endif

    let qfitem = s:qflist[a:idx]
    if !qfitem.valid || !qfitem.bufnr
        let s:qflist = []
        return
    endif

    let space_above = wininfo.winrow - 1
    let space_below = &lines - (wininfo.winrow + wininfo.height - 1) - &cmdheight
    let firstline = qfitem.lnum - s:get('offset') < 1 ? 1 : qfitem.lnum - s:get('offset')
    let height = s:get('height')

    let title = printf('%s (%d/%d)',
            \ bufname(qfitem.bufnr)->fnamemodify(':~:.'),
            \ a:idx + 1,
            \ len(s:qflist)
            \ )

    " Truncate long titles at beginning
    if len(title) > wininfo.width
        let title = '…' .. title[-(wininfo.width-4):]
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
        return s:error('Not enough space to display preview popup')
    endif

    call popup_close(s:winid)
    try
        silent let s:winid = popup_create(qfitem.bufnr, extend(opts, {
                \   'col': wininfo.wincol,
                \   'minheight': height,
                \   'maxheight': height,
                \   'minwidth': wininfo.width - 1,
                \   'maxwidth': wininfo.width - 1,
                \   'firstline': firstline,
                \   'title': title,
                \   'close': 'button',
                \   'padding': [0,1,1,1],
                \   'border': [1,0,0,0],
                \   'borderchars': [' '],
                \   'moved': 'any',
                \   'mapping': v:false,
                \   'filter': funcref('s:popup_filter', [firstline]),
                \   'filtermode': 'n',
                \   'highlight': 'QfPreview',
                \   'borderhighlight': ['QfPreviewTitle'],
                \   'scrollbarhighlight': 'QfPreviewScrollbar',
                \   'thumbhighlight': 'QfPreviewThumb',
                \   'callback': funcref('s:popup_cb')
                \ }))
    catch /^Vim\%((\a\+)\)\=:E325:/
        call s:error('E325: ATTENTION')
    endtry

    " Set firstline to zero to prevent jumps when calling win_execute() #4876
    call popup_setoptions(s:winid, {'firstline': 0})
    call setwinvar(s:winid, '&number', !!s:get('number'))

    if !empty(s:get('sign')->get('text', ''))
        call setwinvar(s:winid, '&signcolumn', 'number')
    endif

    if &g:breakindent
        call setwinvar(s:winid, '&breakindent', 1)
    endif

    if !empty(s:get('sign')) && qfitem.lnum > 0
        call sign_define('QfErrorLine', s:get('sign'))
        call sign_place(0, 'PopUpQfPreview', 'QfErrorLine', qfitem.bufnr, {'lnum': qfitem.lnum})
    endif

    if s:get('matchcolumn') && qfitem.lnum > 0 && qfitem.col > 0
        hi link QfPreviewColumn QuickFixLine
        call matchadd('QfPreviewColumn', printf('\%%%dl\%%%dc', qfitem.lnum, qfitem.col), 1, -1, {'window': s:winid})
    endif
    return s:winid
endfunction

let &cpoptions = s:save_cpo
unlet s:save_cpo
