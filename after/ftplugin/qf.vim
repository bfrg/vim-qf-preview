vim9script
# ==============================================================================
# Preview file with quickfix error in a popup window
# File:         after/ftplugin/qf.vim
# Author:       bfrg <https://github.com/bfrg>
# Website:      https://github.com/bfrg/vim-qf-preview
# Last Change:  May 19, 2022
# License:      Same as Vim itself (see :h license)
# ==============================================================================

# Stop here if user doesn't want ftplugin mappings
if get(g:, 'no_plugin_maps')
    finish
endif

import autoload 'qfpreview.vim'

nnoremap <buffer> <plug>(qf-preview-open) <scriptcmd>qfpreview.Open(line('.') - 1)<cr>

b:undo_ftplugin = get(b:, 'undo_ftplugin', 'execute') .. '| execute "nunmap <buffer> <plug>(qf-preview-open)"'
