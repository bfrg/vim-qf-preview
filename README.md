# vim-qf-preview

vim-qf-preview is a `ftplugin` for the quickfix window to quickly preview the
file with the quickfix error under the cursor in a popup window.

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
Plug "bfrg/vim-qf-preview"
```

## License

Distributed under the same terms as Vim itself. See `:help license`.
