# vim-qf-preview

A plugin for the quickfix and location list windows to quickly preview the file
with the quickfix item under the cursor in a popup window.

**Note:** Plugin requires at least Vim `8.1.1705`.

<dl>
  <p align="center">
  <a href="https://asciinema.org/a/265817">
    <img src="https://asciinema.org/a/265817.png" width="480">
  </a>
  </p>
</dl>

The popup window will always have the same width as the quickfix window.


## Usage

In the quickfix window navigate the cursor to the desired error and press
<kbd>p</kbd> to open a popup window with the file containing the error. The
window is scrolled such that the buffer line with the error is at the top of the
window.

Press <kbd>Ctrl-j</kbd> or <kbd>Ctrl-k</kbd> to scroll the popup window down
or up, respectively.

Pressing <kbd>gg</kbd> or <kbd>G</kbd> will scroll to the top or bottom of the
displayed buffer, respectively.

Press <kbd>x</kbd>, or move the cursor in any direction to close the popup
window.

The height of the popup window can be changed with <kbd>+</kbd> and
<kbd>-</kbd>.


## Configuration

#### b:qfpreview and g:qfpreview

The default key mappings and the height of the popup window can be changed
through the variable `b:qfpreview` in `after/ftplugin/qf.vim`, or alternatively
through the global dictionary `g:qfpreview`. The following `Dictionary` keys are
supported: `scrolldown`, `scrollup`, `close`, and `height`.

Examples:

- Scroll up with <kbd>Ctrl-y</kbd>, and scroll down with <kbd>Ctrl-e</kbd>:
  ```vim
  " in after/ftplugin/qf.vim
  let b:qfpreview = #{scrolldown: "\<C-e>", scrollup: "\<C-y>"}
  ```

- Scroll up with <kbd>K</kbd>, and scroll down with <kbd>J</kbd>, close popup
  window with <kbd>Esc</kbd>:
  ```vim
  " in after/ftplugin/qf.vim
  let b:qfpreview = #{scrolldown: 'J', scrollup: 'K', close: "\<Esc>"}
  ```

- Show 20 text lines in the popup window:
  ```vim
  " in after/ftplugin/qf.vim
  let b:qfpreview = #{height: 20}
  ```

- Alternatively you can also use a `global-variable` in your `vimrc`:
  ```vim
  let g:qfpreview = #{scrolldown: "\<C-e>", scrollup: "\<C-y>", close: "\<Esc>"}
  ```

#### Highlighting

The appearance of the popup window can be configured through the highlighting
groups `QfPreview`, `QfPreviewTitle`, `QfPreviewScrollbar` and `QfPreviewThumb`.
See `:help qfpreview-highlight` for more details.


## Installation

#### Manual Installation

Run the following commands in your terminal:
```
$ cd ~/.vim/pack/git-plugins/start
$ git clone https://github.com/bfrg/vim-qf-preview
$ vim -u NONE -c "helptags vim-qf-preview/doc" -c q
```
**Note:** The directory name `git-plugins` is arbitrary, you can pick any other
name. For more details see `:help packages`.

#### Plugin Managers

Assuming [vim-plug](https://github.com/junegunn/vim-plug) is your favorite
plugin manager, add the following to your `.vimrc`:
```vim
if has('patch-8.1.1705')
    Plug 'bfrg/vim-qf-preview'
endif
```


## License

Distributed under the same terms as Vim itself. See `:help license`.
