vim9script
# ==============================================================================
# Preview file with quickfix error in a popup window
# File:         autoload/qfpreview.vim
# Author:       bfrg <https://github.com/bfrg>
# Website:      https://github.com/bfrg/vim-qf-preview
# Last Change:  Feb 12, 2022
# License:      Same as Vim itself (see :h license)
# ==============================================================================

scriptencoding utf-8

hi def link QfPreview           Pmenu
hi def link QfPreviewTitle      Pmenu
hi def link QfPreviewScrollbar  PmenuSbar
hi def link QfPreviewThumb      PmenuThumb
hi def link QfPreviewColumn     QuickFixLine

const defaults: dict<any> = {
    'height': 15,
    'number': false,
    'offset': 0,
    'sign': {},
    'matchcolumn': false,
    'scrollup': "\<c-k>",
    'scrolldown': "\<c-j>",
    'halfpageup': '',
    'halfpagedown': '',
    'fullpageup': '',
    'fullpagedown': '',
    'top': "\<s-home>",
    'bottom': "\<s-end>",
    'reset': 'r',
    'close': 'q',
    'next': '',
    'previous': ''
}

def Get(key: string): any
    return get(b:, 'qfpreview', get(g:, 'qfpreview', {}))->get(key, defaults[key])
enddef

# Window ID of preview popup window
var popup_id: number = 0

# Cache the quickfix list while popup is open and cycling through item
var qf_list: list<dict<any>> = []

def Error(...msg: list<any>)
    echohl ErrorMsg | echomsg call('printf', msg) | echohl None
enddef

def Reset(winid: number, line: number)
    popup_setoptions(winid, {'firstline': line})
    popup_setoptions(winid, {'firstline': 0})
    if !empty(Get('sign')->get('text', '')) && !has('patch-8.2.1303')
        setwinvar(winid, '&signcolumn', 'number')
    endif
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
    var mappings: dict<func> = {
        [Get('close')]:        (id: number) => popup_close(id),
        [Get('top')]:          (id: number) => win_execute(id, 'normal! gg'),
        [Get('bottom')]:       (id: number) => win_execute(id, 'normal! G'),
        [Get('scrollup')]:     (id: number) => win_execute(id, "normal! \<c-y>"),
        [Get('scrolldown')]:   (id: number) => win_execute(id, "normal! \<c-e>"),
        [Get('halfpageup')]:   (id: number) => win_execute(id, "normal! \<c-u>"),
        [Get('halfpagedown')]: (id: number) => win_execute(id, "normal! \<c-d>"),
        [Get('fullpageup')]:   (id: number) => win_execute(id, "normal! \<c-b>"),
        [Get('fullpagedown')]: (id: number) => win_execute(id, "normal! \<c-f>"),
        [Get('reset')]:        (id: number) => Reset(id, line),
        [Get('next')]:         (id: number) => Cycle(id,  1),
        [Get('previous')]:     (id: number) => Cycle(id, -1)
    }

    filter(mappings, (k: string, _: func): bool => !empty(k))

    if has_key(mappings, key)
        get(mappings, key)(winid)
        return true
    endif

    return false
enddef

def Popup_cb(winid: number, result: number)
    qf_list = []
    if !empty(Get('sign'))
        sign_unplace('PopUpQfPreview')
        if !empty(sign_getdefined('QfErrorLine'))
            sign_undefine('QfErrorLine')
        endif
    endif
enddef

export def Open(idx: number): number
    const wininfo: dict<any> = getwininfo(win_getid())[0]

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
    const firstline: number = qf_item.lnum - Get('offset') < 1 ? 1 : qf_item.lnum - Get('offset')
    var height: number = Get('height')
    var opts: dict<any>

    var title: string = printf('%s (%d/%d)',
        bufname(qf_item.bufnr)->fnamemodify(':~:.'),
        idx + 1,
        len(qf_list)
    )

    # Truncate long titles at beginning
    if len(title) > wininfo.width
        title = '…' .. title[-(wininfo.width - 4) :]
    endif

    if space_above > height
        if space_above == height + 1
            height -= 1
        endif
        opts = {'line': wininfo.winrow - 1, 'pos': 'botleft'}
    elseif space_below >= height
        opts = {'line': wininfo.winrow + wininfo.height, 'pos': 'topleft'}
    elseif space_above > 5
        height = space_above - 2
        opts = {'line': wininfo.winrow - 1, 'pos': 'botleft'}
    elseif space_below > 5
        height = space_below - 2
        opts = {'line': wininfo.winrow + wininfo.height, 'pos': 'topleft'}
    elseif space_above <= 5 || space_below <= 5
        opts = {'line': &lines - &cmdheight, 'pos': 'botleft'}
    else
        Error('Not enough space to display preview popup')
        return 0
    endif

    popup_close(popup_id)
    try
        silent popup_id = popup_create(qf_item.bufnr, extend(opts, {
            'col': wininfo.wincol,
            'minheight': height,
            'maxheight': height,
            'minwidth': wininfo.width - 1,
            'maxwidth': wininfo.width - 1,
            'firstline': firstline,
            'title': title,
            'close': 'button',
            'padding': [0, 1, 1, 1],
            'border': [1, 0, 0, 0],
            'borderchars': [' '],
            'moved': 'any',
            'mapping': false,
            'filter': (winid: number, key: string): bool => Popup_filter(firstline, winid, key),
            'filtermode': 'n',
            'highlight': 'QfPreview',
            'borderhighlight': ['QfPreviewTitle'],
            'scrollbarhighlight': 'QfPreviewScrollbar',
            'thumbhighlight': 'QfPreviewThumb',
            'callback': Popup_cb
         }))
    catch /^Vim\%((\a\+)\)\=:E325:/
        Error('E325: ATTENTION')
    endtry

    # Set firstline to zero to prevent jumps when calling win_execute() #4876
    popup_setoptions(popup_id, {'firstline': 0})
    setwinvar(popup_id, '&number', Get('number'))

    if !empty(Get('sign')->get('text', ''))
        setwinvar(popup_id, '&signcolumn', 'number')
    endif

    if &g:breakindent
        setwinvar(popup_id, '&breakindent', true)
    endif

    if !empty(Get('sign')) && qf_item.lnum > 0
        sign_define('QfErrorLine', Get('sign'))
        sign_place(0, 'PopUpQfPreview', 'QfErrorLine', qf_item.bufnr, {'lnum': qf_item.lnum})
    endif

    if Get('matchcolumn') && qf_item.lnum > 0 && qf_item.col > 0
        const max: number = getbufline(qf_item.bufnr, qf_item.lnum)[0]->len()
        const col: number = qf_item.col >= max ? max : qf_item.col
        matchadd('QfPreviewColumn', printf('\%%%dl\%%%dc', qf_item.lnum, col), 1, -1, {'window': popup_id})
    endif

    return popup_id
enddef
