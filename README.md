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


## Usage

### Quickfix window mapping

To avoid conflicts with other plugins no default key mapping for opening the
popup window is provided. You will first have to bind `<plug>(qf-preview-open)`
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

The following default popup mappings are provided:

- Scroll up/down one text line: <kbd>Ctrl-k</kbd>, <kbd>Ctrl-j</kbd>
- Scroll up/down one half page: <kbd>Ctrl-u</kbd>, <kbd>Ctrl-d</kbd>
- Scroll up/down one full page: <kbd>Ctrl-b</kbd>, <kbd>Ctrl-f</kbd>
- Jump to first/last line of displayed buffer: <kbd>g</kbd>, <kbd>G</kbd>
- Increase/decrease height of popup window: <kbd>+</kbd>, <kbd>-</kbd>
- Close the popup window: <kbd>x</kbd>


## Configuration

### b:qfpreview and g:qfpreview

The default popup key mappings and the appearance of the popup window can be
changed through the variable `b:qfpreview` in `after/ftplugin/qf.vim`, or
alternatively through the global variable `g:qfpreview`. The variable must be a
dictionary containing any of the following entries:

| Entry          | Description                                                      | Default    |
| -------------- | ---------------------------------------------------------------- | ---------- |
| `scrollup`     | Scroll buffer up one text line.                                  | `"\<C-k>"` |
| `scrolldown`   | Scroll buffer down one text line.                                | `"\<C-j>"` |
| `halfpageup`   | Scroll buffer up one half page.                                  | `"\<C-u>"` |
| `halfpagedown` | Scroll buffer down one half page.                                | `"\<C-d>"` |
| `fullpageup`   | Scroll buffer up one full page.                                  | `"\<C-b>"` |
| `fullpagedown` | Scroll buffer down one full page.                                | `"\<C-f>"` |
| `close`        | Close the popup window.                                          | `"x"`      |
| `height`       | Number of text lines to display in the popup window.             | `15`       |
| `scrollbar`    | Display a scrollbar.                                             | `v:true`   |
| `number`       | Enable the `'number'` column in the popup window.                | `v:false`  |
| `mouseclick`   | Enable mouse clicks. Possible values: `none`, `click`, `button`¹ | `"button"` |

¹See <kbd>:help qfpreview.mouseclick</kbd> for more details on each value.

Example:
```vim
" in vimrc
let g:qfpreview = {
    \ 'scrollup': 'k',
    \ 'scrolldown': 'j',
    \ 'halfpageup': 'u',
    \ 'halfpagedown': 'd',
    \ 'fullpageup': 'b',
    \ 'fullpagedown': 'f',
    \ 'scrollbar': 'v:false',
    \ 'mouseclick': 'none',
    \ 'close': 'q',
    \ 'height': 20
    \ }
```

### Highlighting

The highlighting of the popup window can be configured through the highlighting
groups `QfPreview`, `QfPreviewTitle`, `QfPreviewScrollbar` and `QfPreviewThumb`.
See <kbd>:help qfpreview-highlight</kbd> for more details.


## Installation

### Manual Installation

Run the following commands in your terminal:
```bash
$ cd ~/.vim/pack/git-plugins/start
$ git clone https://github.com/bfrg/vim-qf-preview
$ vim -u NONE -c "helptags vim-qf-preview/doc" -c q
```
**Note:** The directory name `git-plugins` is arbitrary, you can pick any other
name. For more details see <kbd>:help packages</kbd>.

### Plugin Managers

Assuming [vim-plug](https://github.com/junegunn/vim-plug) is your favorite
plugin manager, add the following to your `vimrc`:
```vim
if has('patch-8.1.2250')
    Plug 'bfrg/vim-qf-preview'
endif
```


## License

Distributed under the same terms as Vim itself. See <kbd>:help license</kbd>.
