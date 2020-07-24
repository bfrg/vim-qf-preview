" ==============================================================================
" Preview file with quickfix error in a popup window
" File:         autoload/qfpreview.vim
" Author:       bfrg <https://github.com/bfrg>
" Website:      https://github.com/bfrg/vim-qf-preview
" Last Change:  Jul 24, 2020
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
        \ 'offset': 0,
        \ 'sign': {},
        \ 'scrollup': "\<c-k>",
        \ 'scrolldown': "\<c-j>",
        \ 'halfpageup': "\<c-u>",
        \ 'halfpagedown': "\<c-d>",
        \ 'fullpageup': "\<c-b>",
        \ 'fullpagedown': "\<c-f>",
        \ 'close': 'q'
        \ }

let s:get = {x -> get(b:, 'qfpreview', get(g:, 'qfpreview', {}))->get(x, s:defaults[x])}

function! s:setheight(winid, step) abort
    let height = popup_getoptions(a:winid).minheight
    let newheight = height + a:step > 0 ? height + a:step : 1
    call popup_setoptions(a:winid, {'minheight': newheight, 'maxheight': newheight})
    if !empty(s:get('sign')->get('text', ''))
        call setwinvar(a:winid, '&signcolumn', 'number')
    endif
endfunction

function! s:popup_filter(line, winid, key) abort
    if a:key ==# s:get('scrollup')
        call win_execute(a:winid, "normal! \<c-y>")
    elseif a:key ==# s:get('scrolldown')
        call win_execute(a:winid, "normal! \<c-e>")
    elseif a:key ==# s:get('halfpageup')
        call win_execute(a:winid, "normal! \<c-u>")
    elseif a:key ==# s:get('halfpagedown')
        call win_execute(a:winid, "normal! \<c-d>")
    elseif a:key ==# s:get('fullpageup')
        call win_execute(a:winid, "normal! \<c-b>")
    elseif a:key ==# s:get('fullpagedown')
        call win_execute(a:winid, "normal! \<c-f>")
    elseif a:key ==# s:get('close')
        call popup_close(a:winid)
    elseif a:key ==# 'g'
        call win_execute(a:winid, 'normal! gg')
    elseif a:key ==# 'G'
        call win_execute(a:winid, 'normal! G')
    elseif a:key ==# '+'
        call s:setheight(a:winid, 1)
    elseif a:key ==# '-'
        call s:setheight(a:winid, -1)
    elseif a:key ==# 'r'
        call popup_setoptions(a:winid, {'firstline': a:line})
        call popup_setoptions(a:winid, {'firstline': 0})
        " Note: after popup_setoptions() 'signcolumn' needs to be reset again
        if !empty(s:get('sign')->get('text', ''))
            call setwinvar(a:winid, '&signcolumn', 'number')
        endif
    else
        return v:false
    endif
    return v:true
endfunction

function! qfpreview#open(idx) abort
    let wininfo = getwininfo(win_getid())[0]
    let qflist = wininfo.loclist ? getloclist(0) : getqflist()
    let qfitem = qflist[a:idx]

    if !qfitem.valid || !qfitem.bufnr
        return
    endif

    let space_above = wininfo.winrow - 1
    let space_below = &lines - (wininfo.winrow + wininfo.height - 1) - &cmdheight
    let lnum = qfitem.lnum < 1 ? 1 : qfitem.lnum
    let firstline = qfitem.lnum - s:get('offset') < 1 ? 1 : qfitem.lnum - s:get('offset')
    let height = s:get('height')

    let title = printf('%s (%d/%d)',
            \ bufname(qfitem.bufnr)->fnamemodify(':~:.'),
            \ a:idx + 1,
            \ len(qflist)
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
        echohl ErrorMsg
        echomsg 'qfpreview: Not enough space to display popup window.'
        echohl None
        return
    endif

    silent let winid = popup_create(qfitem.bufnr, extend(opts, {
            \   'col': wininfo.wincol,
            \   'minheight': height,
            \   'maxheight': height,
            \   'minwidth': wininfo.width - 1,
            \   'maxwidth': wininfo.width - 1,
            \   'firstline': firstline,
            \   'title': title,
            \   'close': s:get('mouseclick'),
            \   'padding': [0,1,1,1],
            \   'border': [1,0,0,0],
            \   'borderchars': [' '],
            \   'moved': 'any',
            \   'mapping': v:false,
            \   'filter': funcref('s:popup_filter', [firstline]),
            \   'filtermode': 'n',
            \   'highlight': 'QfPreview',
            \   'scrollbar': s:get('scrollbar'),
            \   'borderhighlight': ['QfPreviewTitle'],
            \   'scrollbarhighlight': 'QfPreviewScrollbar',
            \   'thumbhighlight': 'QfPreviewThumb',
            \   'callback': {... -> !empty(s:get('sign'))
            \     ? [sign_unplace('PopUpQfPreview'), sign_undefine('QfErrorLine')]
            \     : 0
            \   }
            \ }))

    " Set firstline to zero to prevent jumps when calling win_execute() #4876
    call popup_setoptions(winid, {'firstline': 0})
    call setwinvar(winid, '&number', !!s:get('number'))

    if !empty(s:get('sign')->get('text', ''))
        call setwinvar(winid, '&signcolumn', 'number')
    endif

    if !empty(s:get('sign'))
        call sign_define('QfErrorLine', s:get('sign'))
        call sign_place(0, 'PopUpQfPreview', 'QfErrorLine', qfitem.bufnr, {'lnum': lnum})
    endif

    return winid
endfunction

let &cpoptions = s:save_cpo
unlet s:save_cpo
