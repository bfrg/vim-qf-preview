# vim-qf-preview

A plugin for the quickfix and location list windows to quickly preview the file
with the quickfix item under the cursor in a popup window.

**Note:** The plugin requires at least Vim `8.1.1705`.

| Before                            | After                             |
|:---------------------------------:|:---------------------------------:|
| ![qf-bottom-1][Quickfix-bottom-1] | ![qf-bottom-2][Quickfix-bottom-2] |
| ![qf-left-1][Quickfix-left-1]     | ![qf-left-2][Quickfix-left-2]     |
| ![qf-top-1][Quickfix-top-1]       | ![qf-top-2][Quickfix-top-2]       |


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

#### Configuration

The appearance of the popup window can be configured using the highlight groups
`QfPreview`, `QfPreviewTitle`, `QfPreviewScrollbar` and `QfPreviewThumb`. See
`:help qfpreview-highlight` for more details.


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

[Quickfix-bottom-1]: https://user-images.githubusercontent.com/6266600/64166843-385b8580-ce48-11e9-9412-03b545e795f6.png
[Quickfix-bottom-2]: https://user-images.githubusercontent.com/6266600/64166855-3db8d000-ce48-11e9-87ac-5773d201e11c.png "Popup window appears above quickfix window"
[Quickfix-left-1]: https://user-images.githubusercontent.com/6266600/64167089-c6377080-ce48-11e9-9742-51ebfad6f6b2.png
[Quickfix-left-2]: https://user-images.githubusercontent.com/6266600/64167088-c59eda00-ce48-11e9-9d4e-9a65a8c40f62.png "Popup window appears above quickfix window with same width"
[Quickfix-top-1]: https://user-images.githubusercontent.com/6266600/64167267-31814280-ce49-11e9-879a-b9a1275a682d.png
[Quickfix-top-2]: https://user-images.githubusercontent.com/6266600/64167268-31814280-ce49-11e9-92a1-bc02be2096ac.png "Popup window appears below quickfix window"
