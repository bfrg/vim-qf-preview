# vim-qf-preview

A plugin for the quickfix and location list windows to quickly preview the file
with the quickfix item under the cursor in a popup window.


## Usage

In the quickfix window navigate the cursor to the desired error and press
<kbd>p</kbd> to open a popup window with the file containing the error. The
window is scrolled such that the buffer line with the error is at the top of the
window.

Press <kbd>Ctrl-j</kbd> or <kbd>Ctrl-k</kbd> to scroll the popup window down
or up, respectively.

Pressing <kbd>gg</kbd> or <kbd>G</kbd> will scroll to the top or bottom of the
displayed buffer, respectively.

Press either <kbd>x</kbd> or <kbd>Esc</kbd>, or move the cursor in any direction
to close the popup window.

#### Mouse events

While the mouse pointer is on the popup window, mouse scroll events will cause
the text to scroll up or down as one would expect. Click on `X` in the top right
corner to close the window.


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
Plug 'bfrg/vim-qf-preview'
```


## License

Distributed under the same terms as Vim itself. See `:help license`.
