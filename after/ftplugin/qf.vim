" ==============================================================================
" Preview file with quickfix error in a popup window
" File:         after/ftplugin/qf.vim
" Author:       bfrg <https://github.com/bfrg>
" Website:      https://github.com/bfrg/vim-qf-preview
" Last Change:  Oct 28, 2019
" License:      Same as Vim itself (see :h license)
" ==============================================================================

let s:save_cpo = &cpoptions
set cpoptions&vim

" Stop here if user doesn't want ftplugin mappings
if exists('g:no_plugin_maps') || !has('patch-8.1.1705')
    finish
endif

let s:var = get(b:, 'qfpreview', get(g:, 'qfpreview', {}))
if has_key(s:var, 'preview')
  let s:key = s:var['preview']
else
  let s:key = 'p'
endif

execute 'nnoremap <silent> <buffer> ' . s:key . ' :<c-u>call qfpreview#open(line(".")-1)<cr>'

let b:undo_ftplugin = get(b:, 'undo_ftplugin', 'execute') . '| execute "nunmap <buffer> ' . s:key . '"'

unlet s:var
unlet s:key

let &cpoptions = s:save_cpo
unlet s:save_cpo
