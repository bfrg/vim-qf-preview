# vim-qf-preview

A plugin for the quickfix and location list windows to quickly preview the file
with the quickfix item under the cursor in a popup window.

**Note:** Plugin requires at least Vim `8.1.2250`.

<dl>
  <p align="center">
  <a href="https://asciinema.org/a/265817">
    <img src="https://asciinema.org/a/265817.png" width="480">
  </a>
  </p>
</dl>

The popup window will always have the same width as the quickfix window.


## Usage

### Quickfix window mapping

To avoid conflicts with other plugins no default key mappings for opening the
popup window are provided. You will first have to bind `<plug>(qf-preview-open)`
to a key-sequence of your choice.

For example, to open the popup window with <kbd>p</kbd>, add the following to
`~/.vim/after/ftplugin/qf.vim`:
```vim
nmap <buffer> p <plug>(qf-preview-open)
```

Or alternatively, if you prefer to keep your plugin settings in your `vimrc`:
```vim
augroup qfpreview
  autocmd!
  autocmd FileType qf nmap <buffer> p <plug>(qf-preview-open)
augroup END
```

Now navigate the cursor in the quickfix window to the desired error and press
<kbd>p</kbd> to open a popup window with the file containing the error. The
window is scrolled such that the buffer line with the error is at the top of the
popup window.

### Popup window mappings

The following keys can be used while the popup window is visible:

| Key               | Description                                 | Configuration           |
| ----------------- | ------------------------------------------- | ----------------------- |
| <kbd>Ctrl-k</kbd> | Scroll buffer up one text line.             | `qfpreview.scrollup`    |
| <kbd>Ctrl-j</kbd> | Scroll buffer down one text line.           | `qfpreview.scrolldown`  |
| <kbd>Ctrl-u</kbd> | Scroll buffer up one half page.             | `qfpreview.halfpageup`  |
| <kbd>Ctrl-d</kbd> | Scroll buffer down one half page.           | `qfpreview.halfpagedown`|
| <kbd>Ctrl-b</kbd> | Scroll buffer up one full page.             | `qfpreview.fullpageup`  |
| <kbd>Ctrl-f</kbd> | Scroll buffer down one full page.           | `qfpreview.fullpagedown`|
| <kbd>x</kbd>      | Close the popup window.                     | `qfpreview.close`       |
| <kbd>g</kbd>      | Scroll to top of displayed buffer.          | -                       |
| <kbd>G</kbd>      | Scroll to bottom of displayed buffer.       | -                       |
| <kbd>+</kbd>      | Increase height of popup window by one line.| -                       |
| <kbd>-</kbd>      | Decrease height of popup window by one line.| -                       |


## Configuration

### b:qfpreview and g:qfpreview

The default popup key mappings and the height of the popup window can be changed
through the variable `b:qfpreview` in `after/ftplugin/qf.vim`, or alternatively
through the global variable `g:qfpreview`. In addition to the `Dictionary` keys
listed in the above table, the initial height of the popup window can be set
through the `height` entry.

Example:
```vim
" in vimrc
let g:qfpreview = #{
    \ scrollup: 'k',
    \ scrolldown: 'j',
    \ halfpageup: 'u',
    \ halfpagedown: 'd',
    \ fullpageup: 'b',
    \ fullpagedown: 'f',
    \ close: 'q',
    \ height: 20
    \ }
```

### Highlighting

The appearance of the popup window can be configured through the highlighting
groups `QfPreview`, `QfPreviewTitle`, `QfPreviewScrollbar` and `QfPreviewThumb`.
See `:help qfpreview-highlight` for more details.


## Installation

### Manual Installation

Run the following commands in your terminal:
```bash
$ cd ~/.vim/pack/git-plugins/start
$ git clone https://github.com/bfrg/vim-qf-preview
$ vim -u NONE -c "helptags vim-qf-preview/doc" -c q
```
**Note:** The directory name `git-plugins` is arbitrary, you can pick any other
name. For more details see `:help packages`.

### Plugin Managers

Assuming [vim-plug](https://github.com/junegunn/vim-plug) is your favorite
plugin manager, add the following to your `vimrc`:
```vim
if has('patch-8.1.2250')
    Plug 'bfrg/vim-qf-preview'
endif
```


## License

Distributed under the same terms as Vim itself. See `:help license`.
