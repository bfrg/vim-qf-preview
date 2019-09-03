" ==============================================================================
" Preview file with quickfix error in a popup window
" File:         autoload/qfpreview.vim
" Author:       bfrg <https://github.com/bfrg>
" Website:      https://github.com/bfrg/vim-qf-preview
" Last Change:  Sep 3, 2019
" License:      Same as Vim itself (see :h license)
" ==============================================================================

scriptencoding utf-8

let s:save_cpo = &cpoptions
set cpoptions&vim

" Holds information about the currently previewed buffer
" Valid keys:
"   bufnr     - buffer number as obtained with bufnr()
"   bufloaded - 1 if buffer has already been loaded [bufloaded()] BEFORE
"               displayed in the popup window, 0 otherwise
"   buflisted - 1 if buffer was already listed [buflisted()] before displayed in
"               the popup window, 0 otherwise
let s:bufr = {}

" We need to delete the buffer using a timer since the callback function is
" invoked just BEFORE the popup window is closed, see :h popup_close(), and
" deleting the buffer while its still displayed in the popup window doesn't
" work.
"
" Deleting the displayed buffer after the popup window is closed has two
" reasons:
"
" 1. Free the memory allocated for the buffer (if we don't open the buffer in a
"    regular window, we probably won't need it anymore).
"
" 2. If a swap file already exists for the buffer (because it is edited in
"    another Vim instance), Vim won't show the E325 attention screen and ask the
"    user for input, when the buffer is later edited in a regular window.
"    See also 'peculiarities' under :h preview-popup.
function! s:popup_close_cb(winid, result) abort
    call timer_start(1, function('s:cleanup'))
endfunction

function! s:cleanup(timer) abort
    " If user hits <cr> to edit the buffer, keep the buffer listed and loaded
    " and don't remove it again
    if bufwinid(s:bufr.bufnr) != -1
        return
    endif

    if !s:bufr.bufloaded
        execute 'bunload' s:bufr.bufnr
    endif
    if !s:bufr.buflisted
        silent! execute 'bdelete' s:bufr.bufnr
    endif
endfunction

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
    elseif a:key ==# 'g'
        call popup_setoptions(a:winid, #{firstline: 1})
        return v:true
    elseif a:key ==# 'G'
        let height = popup_getpos(a:winid).core_height
        call win_execute(a:winid, 'let g:nlines = line("$")')
        call popup_setoptions(a:winid, #{firstline: g:nlines - height + 1})
        unlet g:nlines
        return v:true
    elseif a:key ==# 'x' || a:key ==# "\<esc>"
        call popup_close(a:winid)
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
    let title = printf('%s (%d/%d)', bufname(qfitem.bufnr), a:idx+1, len(qflist))

    " Truncate long titles
    if len(title) > wininfo.width
        let width = wininfo.width - 4
        let title = '…' . title[-width:]
    endif

    " Default height (padding of 1 at top and bottom not incluced)
    let height = 15

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
            \ firstline: qfitem.lnum,
            \ title: title,
            \ close: 'button',
            \ padding: [0,1,1,1],
            \ border: [1,0,0,0],
            \ borderchars: [' '],
            \ moved: 'any',
            \ filter: function('s:popup_filter'),
            \ callback: function('s:popup_close_cb'),
            \ highlight: 'QfPreview',
            \ borderhighlight: ['QfPreviewTitle'],
            \ scrollbarhighlight: 'QfPreviewScrollbar',
            \ thumbhighlight: 'QfPreviewThumb'
            \ })

    hi def link QfPreview Pmenu
    hi def link QfPreviewTitle Pmenu
    hi def link QfPreviewScrollbar PmenuSbar
    hi def link QfPreviewThumb PmenuThumb

    let s:bufr = {
            \ 'bufnr': qfitem.bufnr,
            \ 'bufloaded': bufloaded(qfitem.bufnr) ? 1 : 0,
            \ 'buflisted': buflisted(qfitem.bufnr) ? 1 : 0
            \ }

    " If a swap file already exists for a buffer that is passed to
    " popup_create(), Vim will echo the E325 attention message but won't present
    " the swap-exists-choices dialog. When the popup window is closed, the
    " buffer will be unlisted but NOT unloaded.  If the buffer is later edited
    " in a regular window, the user might not remember that it is also edited in
    " another Vim instance, and end up with two versions of the same file.
    " Therefore, we suppress the E325 message entirely and :bunload the buffer
    " in the popup callback.
    silent! let winid = popup_create(qfitem.bufnr, opts)

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
