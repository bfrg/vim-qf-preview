" ==============================================================================
" Preview file with quickfix error in a popup window
" File:         after/ftplugin/qf.vim
" Author:       bfrg <https://github.com/bfrg>
" Website:      https://github.com/bfrg/vim-qf-preview
" Last Change:  Aug 9, 2020
" License:      Same as Vim itself (see :h license)
" ==============================================================================

let s:save_cpo = &cpoptions
set cpoptions&vim

let b:undo_ftplugin = get(b:, 'undo_ftplugin', 'execute')

" Open qf-preview popup automatically
if get(b:, 'qfpreview', get(g:, 'qfpreview', {}))->get('auto') && has('patch-8.2.1377')
    augroup qfpreview
        autocmd! * <buffer>
        autocmd CursorMoved <buffer> call qfpreview#on_cursor_moved()
    augroup END
    let b:undo_ftplugin ..= ' | execute "autocmd! qfpreview CursorHold <buffer>"'
endif

" Stop here if user doesn't want ftplugin mappings
if exists('g:no_plugin_maps') || !has('patch-8.1.2250')
    finish
endif

nnoremap <silent> <buffer> <plug>(qf-preview-open) :<c-u>call qfpreview#open(line('.')-1)<cr>

let b:undo_ftplugin ..= ' | execute "nunmap <buffer> <plug>(qf-preview-open)"'

let &cpoptions = s:save_cpo
unlet s:save_cpo
