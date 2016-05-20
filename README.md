# intero.nvim [![unlicense](https://img.shields.io/badge/un-license-green.svg?style=flat)](http://unlicense.org)

Do you use [Neovim](https://neovim.io) to work on Haskell code?
Do you want really, *really fast* autocompletion and stuff?
Do you already [use GHCi a lot](http://chrisdone.com/posts/haskell-repl)?

Well, this project is for you.

So,

- GHCi is the Haskell REPL. It has a `:complete` command.
- [Intero](https://github.com/chrisdone/intero) is a fork of GHCi that adds `:uses`, `:loc-at`, `:type-at`.
- [My fork of intero](https://github.com/myfreeweb/intero) adds a MessagePack RPC server that exposes those commands!
- This plugin connects to that server using Neovim's built-in MessagePack RPC client.

As a result, you get very robust and lightning fast omni-completion, go-to-definition, go-to-uses, type-of-expression.

## Installation

1. Clone `https://github.com/myfreeweb/intero.git` with `git` and install with `stack install`
2. Install this plugin (`https://github.com/myfreeweb/intero.nvim.git`) with your favorite Vim package manager
3. Run the REPL at your project root with `stack ghci --with-ghc intero`
4. Configure your Neovim!

Example `ftplugin/haskell.vim`:

```viml
setlocal omnifunc=intero#omnifunc

vnoremap <buffer> <Leader>G :InteroGoto<CR>
vnoremap <buffer> <Leader>T :InteroType<CR>
vnoremap <buffer> <Leader>U :InteroUses<CR>
nnoremap <buffer> <Leader>m :call intero#ensurebufmodule()<CR>:call VimuxSendText(":m + ".b:intero_module."\n:reload\n")<CR>
```

(The last line uses [Vimux](https://github.com/benmills/vimux) to tell Intero to load the current module.)

## Contributing

Please feel free to submit pull requests!

By participating in this project you agree to follow the [Contributor Code of Conduct](http://contributor-covenant.org/version/1/4/).

[The list of contributors is available on GitHub](https://github.com/myfreeweb/intero.nvim/graphs/contributors).

## License

This is free and unencumbered software released into the public domain.  
For more information, please refer to the `UNLICENSE` file or [unlicense.org](http://unlicense.org).
