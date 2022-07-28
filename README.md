# vim-qf-preview

A plugin for the quickfix and location list window to quickly preview the file
with the quickfix item under the cursor in a popup window.

<dl>
  <p align="center">
  <a href="https://asciinema.org/a/265817">
    <img src="https://asciinema.org/a/265817.png" width="480">
  </a>
  </p>
</dl>


## Requirements

Vim `>= 9.0.0`


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
- Scroll to first/last line of displayed buffer: <kbd>Shift-Home</kbd>,
  <kbd>Shift-End</kbd>
- Scroll back to error line ("reset"): <kbd>r</kbd>
- Close the popup window: <kbd>q</kbd>, <kbd>Ctrl-c</kbd>


## Configuration

### b:qfpreview and g:qfpreview

The default popup key mappings and the appearance of the popup window can be
configured through the variable `b:qfpreview` in `after/ftplugin/qf.vim`, or
alternatively through the global variable `g:qfpreview`. The variable must be a
dictionary containing any of the following entries:

| Entry          | Description                                                | Default       |
| -------------- | ---------------------------------------------------------- | ------------- |
| `top`          | Scroll to the first line of the buffer.                    | `"\<S-Home>"` |
| `bottom`       | Scroll to the bottom of the buffer.                        | `"\<S-End>"`  |
| `scrollup`     | Scroll window up one text line.                            | `"\<C-k>"`    |
| `scrolldown`   | Scroll window down one text line.                          | `"\<C-j>"`    |
| `halfpageup`   | Scroll window up one half page.                            | none          |
| `halfpagedown` | Scroll window down one half page.                          | none          |
| `fullpageup`   | Scroll window up one full page.                            | none          |
| `fullpagedown` | Scroll window down one full page.                          | none          |
| `reset`        | Scroll window back to error line.                          | `"r"`         |
| `close`        | Close the popup window.                                    | `"q"`         |
| `next`         | Navigate to next quickfix item in current list.            | none          |
| `previous`     | Navigate to previous quickfix item in current list.        | none          |
| `height`       | Number of text lines to display in the popup window.       | `15`          |
| `offset`       | Number of buffer lines to show above the error line.       | `0`           |
| `number`       | Enable the `'number'` column in the popup window.          | `v:false`     |
| `sign`         | Place a `sign` on the error line in the displayed buffer.¹ | `{}`          |
| `matchcolumn`  | Highlight column of current quickfix item in popup window. | `v:false`     |

¹For valid `sign` attributes see <kbd>:help qfpreview.sign</kbd> and the
[examples](#examples) below.

### Highlighting

The highlighting of the popup window can be configured through the highlighting
groups `QfPreview`, `QfPreviewTitle`, `QfPreviewScrollbar`, `QfPreviewThumb` and
`QfPreviewColumn`. See <kbd>:help qfpreview-highlight</kbd> for more details.

### Examples

1. Override the popup scrolling keys:
   ```vim
   vim9script
   g:qfpreview = {
       top: g,
       bottom: G,
       scrollup: 'k',
       scrolldown: 'j',
       halfpageup: 'u',
       halfpagedown: 'd',
       fullpageup: 'b',
       fullpagedown: 'f',
       next: 'n',
       previous: 'p'
   }
   ```
2. Place a sign in the buffer at the error line and highlight the whole line
   using `CursorLine`:
   ```vim
   g:qfpreview = {sign: {linehl: 'CursorLine'}}
   ```
3. Instead of highlighting the whole line, display a sign in the `'signcolumn'`:
   ```vim
   g:qfpreview = {sign: {text: '>>', texthl: 'Search'}}
   ```
4. Same as 3., but also enable the `'number'` column. In this case the placed
   sign is shown in the `'number'` column:
   ```vim
   g:qfpreview = {number: 1, sign: {text: '>>', texthl: 'Todo'}}
   ```

Screenshots of 2., 3. and 4.:
![out](https://user-images.githubusercontent.com/6266600/77472775-b4cdaa00-6e14-11ea-8abd-d55c47fdeda7.png)


## Installation

Run the following commands in your terminal:
```bash
$ cd ~/.vim/pack/git-plugins/start
$ git clone https://github.com/bfrg/vim-qf-preview
$ vim -u NONE -c 'helptags vim-qf-preview/doc | quit'
```
**Note:** The directory name `git-plugins` is arbitrary, you can pick any other
name. For more details see <kbd>:help packages</kbd>. Alternatively, use your
favorite plugin manager.


## License

Distributed under the same terms as Vim itself. See <kbd>:help license</kbd>.
