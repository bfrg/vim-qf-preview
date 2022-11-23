vim9script
# ==============================================================================
# Preview file with quickfix error in a popup window
# File:         autoload/qfpreview.vim
# Author:       bfrg <https://github.com/bfrg>
# Website:      https://github.com/bfrg/vim-qf-preview
# Last Change:  Nov 23, 2022
# License:      Same as Vim itself (see :h license)
# ==============================================================================

scriptencoding utf-8

hlset([
    {name: 'QfPreview',          linksto: 'Pmenu',        default: true},
    {name: 'QfPreviewTitle',     linksto: 'Pmenu',        default: true},
    {name: 'QfPreviewScrollbar', linksto: 'PmenuSbar',    default: true},
    {name: 'QfPreviewThumb',     linksto: 'PmenuThumb',   default: true},
    {name: 'QfPreviewColumn',    linksto: 'QuickFixLine', default: true},
])

const defaults: dict<any> = {
    height: 15,
    number: false,
    offset: 3,
    sign: {linehl: 'CursorLine'},
    matchcolumn: true,
    scrollup: "\<c-k>",
    scrolldown: "\<c-j>",
    halfpageup: '',
    halfpagedown: '',
    fullpageup: '',
    fullpagedown: '',
    top: "\<s-home>",
    bottom: "\<s-end>",
    reset: 'r',
    close: 'q',
    next: '',
    previous: ''
}

def Getopt(key: string): any
    return get(b:, 'qfpreview', get(g:, 'qfpreview', {}))->get(key, defaults[key])
enddef

# Window ID of preview popup window
var popup_id: number = 0

# Cache the quickfix list while popup is open and cycling through item
var qf_list: list<dict<any>> = []

def Error(msg: string)
    echohl ErrorMsg | echomsg msg | echohl None
enddef

def Display2byte(str: string, virtcol: number): number
    const ts_old: number = &tabstop
    &tabstop = 8
    var col: number
    try
        col = match(str, $'\%{virtcol}v') + 1
    finally
        &tabstop = ts_old
    endtry
    return col
enddef

def Cycle(winid: number, step: number)
    var cur_pos: list<number> = getpos('.')
    var new_lnum: number = line('.') + step > line('$')
        ? line('$')
        : line('.') + step < 1 ? 1 : line('.') + step

    while (!qf_list[new_lnum - 1].valid || qf_list[new_lnum - 1].bufnr < 1)
          && new_lnum > 0
          && new_lnum < line('$')
        new_lnum += step
    endwhile

    if new_lnum == cur_pos[1] || !qf_list[new_lnum - 1].valid || qf_list[new_lnum - 1].bufnr < 1
        return
    endif

    popup_close(winid)
    cur_pos[1] = new_lnum
    setpos('.', cur_pos)
    Open(line('.') - 1)
enddef

def Popup_filter(line: number, winid: number, key: string): bool
    if !empty(Getopt('close')) && key == Getopt('close')
        popup_close(winid)
    elseif !empty(Getopt('top')) && key == Getopt('top')
        win_execute(winid, 'normal! gg')
    elseif !empty(Getopt('bottom')) && key == Getopt('bottom')
        win_execute(winid, 'normal! G')
    elseif !empty(Getopt('scrollup')) && key == Getopt('scrollup')
        win_execute(winid, "normal! \<c-y>")
    elseif !empty(Getopt('scrolldown')) && key == Getopt('scrolldown')
        win_execute(winid, "normal! \<c-e>")
    elseif !empty(Getopt('halfpageup')) && key == Getopt('halfpageup')
        win_execute(winid, "normal! \<c-u>")
    elseif !empty(Getopt('halfpagedown')) && key == Getopt('halfpagedown')
        win_execute(winid, "normal! \<c-d>")
    elseif !empty(Getopt('fullpageup')) && key == Getopt('fullpageup')
        win_execute(winid, "normal! \<c-b>")
    elseif !empty(Getopt('fullpagedown')) && key == Getopt('fullpagedown')
        win_execute(winid, "normal! \<c-f>")
    elseif !empty(Getopt('reset')) && key == Getopt('reset')
        popup_setoptions(winid, {firstline: line})
        popup_setoptions(winid, {firstline: 0})
    elseif !empty(Getopt('next')) && key == Getopt('next')
        Cycle(winid, 1)
    elseif !empty(Getopt('previous')) && key == Getopt('previous')
        Cycle(winid, -1)
    else
        return false
    endif
    return true
enddef

def Popup_cb(winid: number, result: number)
    qf_list = []
    sign_unplace('PopUpQfPreview')
    if !empty(sign_getdefined('QfErrorLine'))
        sign_undefine('QfErrorLine')
    endif
enddef

export def Open(idx: number): number
    const wininfo: dict<any> = win_getid()->getwininfo()[0]

    if empty(qf_list)
        qf_list = wininfo.loclist ? getloclist(0) : getqflist()
        if empty(qf_list)
            return 0
        endif
    endif

    const qf_item: dict<any> = qf_list[idx]
    if !qf_item.valid || qf_item.bufnr < 1 || !bufexists(qf_item.bufnr)
        qf_list = []
        return 0
    endif

    const space_above: number = wininfo.winrow - 1
    const space_below: number = &lines - (wininfo.winrow + wininfo.height - 1) - &cmdheight
    const firstline: number = qf_item.lnum - Getopt('offset') < 1 ? 1 : qf_item.lnum - Getopt('offset')
    var height: number = Getopt('height')
    var title: string = $'{qf_item.bufnr->bufname()->fnamemodify(':~:.')} ({idx + 1}/{len(qf_list)})'
    var line: number
    var pos: string

    # Truncate long titles at beginning
    if strwidth(title) > wininfo.width
        title = '…' .. title[-(wininfo.width - 4) :]
    endif

    if space_above > height
        if space_above == height + 1
            height -= 1
        endif
        line = wininfo.winrow - 1
        pos = 'botleft'
    elseif space_below >= height
        line = wininfo.winrow + wininfo.height
        pos = 'topleft'
    elseif space_above > 5
        height = space_above - 2
        line = wininfo.winrow - 1
        pos = 'botleft'
    elseif space_below > 5
        height = space_below - 2
        line = wininfo.winrow + wininfo.height
        pos = 'topleft'
    elseif space_above <= 5 || space_below <= 5
        line = &lines - &cmdheight
        pos = 'botleft'
    else
        Error('Not enough space to display preview popup')
        return 0
    endif

    popup_close(popup_id)
    silent popup_id = popup_create(qf_item.bufnr, {
        pos: pos,
        line: line,
        col: wininfo.wincol,
        minheight: height,
        maxheight: height,
        minwidth: wininfo.width - 2,
        maxwidth: wininfo.width - 2,
        firstline: firstline,
        title: title,
        close: 'button',
        hidden: true,
        padding: [0, 1, 1, 1],
        border: [1, 0, 0, 0],
        borderchars: [' '],
        moved: 'any',
        mapping: false,
        filter: (winid: number, key: string): bool => Popup_filter(firstline, winid, key),
        filtermode: 'n',
        highlight: 'QfPreview',
        borderhighlight: ['QfPreviewTitle'],
        scrollbarhighlight: 'QfPreviewScrollbar',
        thumbhighlight: 'QfPreviewThumb',
        callback: Popup_cb
    })

    # Set firstline to zero to prevent jumps when calling win_execute() #4876
    popup_setoptions(popup_id, {firstline: 0})
    setwinvar(popup_id, '&number', Getopt('number'))
    setwinvar(popup_id, '&smoothscroll', true)
    setwinvar(popup_id, '&conceallevel', 2)

    if !empty(Getopt('sign')->get('text', ''))
        setwinvar(popup_id, '&signcolumn', 'number')
    endif

    if &g:breakindent
        setwinvar(popup_id, '&breakindent', true)
    endif

    if !empty(Getopt('sign')) && qf_item.lnum > 0
        sign_define('QfErrorLine', Getopt('sign'))
        sign_place(0, 'PopUpQfPreview', 'QfErrorLine', qf_item.bufnr, {lnum: qf_item.lnum})
    endif

    if popup_getpos(popup_id).scrollbar > 0
        popup_move(popup_id, {
            minwidth: wininfo.width - 3,
            maxwidth: wininfo.width - 3
        })
    endif
    popup_show(popup_id)

    if Getopt('matchcolumn') && qf_item.lnum > 0 && qf_item.col > 0
        var lines: list<string> = getbufline(qf_item.bufnr, qf_item.lnum, qf_item.end_lnum > 0 ? qf_item.end_lnum : qf_item.lnum)
        var col: number = qf_item.col
        const max_col: number = strlen(lines[0])
        var end_col: number = qf_item.end_col

        if qf_item.vcol == 1
            col = Display2byte(lines[0], qf_item.col)
            if qf_item.end_col > 0
                end_col = Display2byte(lines[-1], qf_item.end_col)
            endif
        endif

        if col > max_col
            col = max_col
        endif

        if qf_item.end_col > 0
            const max_end_col: number = strlen(lines[-1]) + 1
            if end_col > max_end_col
                end_col = max_end_col
            endif
            lines[-1] = strpart(lines[-1], 0, end_col - 1)
            lines[0] = strpart(lines[0], col - 1)
            const charlen: number = lines->join("\n")->strcharlen()
            matchadd('QfPreviewColumn', $'\%{qf_item.lnum}l\%{col}c\_.\{{{charlen}}}', 1, -1, {window: popup_id})
        else
            matchaddpos('QfPreviewColumn', [[qf_item.lnum, col]], 1, -1, {window: popup_id})
        endif
    endif

    return popup_id
enddef
