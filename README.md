# Dotfiles

My dotfiles, for better/faster/simpler host management and more fun!

## License

The MIT license is used here, see [LICENSE].

## Status

Development is always ongoing. Changes will be made when I need them, and they might be massive (like moving to a different dotfiles management system).

## Support and contributing

Aaahm… Well… **Nope**. It's a private thing, so you are on your own, as I am.

## Contributing

This repository is not open for contributions, but I might accept suggestions. Please use the repository's hosting platform's tools for this.

## Usage

1. install [chezmoi]
1. initialize `chezmoi` using this repository

   > just pick one, they are different mirrors of the same repository

   ```sh
   chezmoi init https://gitlab.com/mckie/dotfiles.git
   chezmoi init https://github.com/mcereda/dotfiles.git
   ```

1. optionally, create the [chezmoidata.format] data file in the repository root folder:

   ```yaml
   # file at $(chezmoi source-path)/.chezmoidata.yaml
   name: Johnny B. Good
   email: …
   ```

   values in here will be used to override the templates defaults; see [gotchas] for details

1. check and apply the changes using chezmoi

   ```sh
   chezmoi diff
   chezmoi apply
   ```

## Design decisions

Due to less time in general, performance issues and the decision to not always do everything by myself:

- the files are managed using [chezmoi], just because it offers lots of features (templating and encryption, mostly) and I find it easier than [GNU stow] or other similar projects ([yadm])
- chezmoi's configuration files format of choice is **YAML**, because I find it is easy to read, write, and merge in the code
- files containing any private data shall be encrypted; see [encryption](#encryption) for details
- shell-related files shall focus on performance as I am easily annoied by slow prompts; see [shell files conventions](#shell-files-conventions) for details

### Encryption

The default [encryption] method of choice is `gpg`.

### Shell-related files conventions

- for posix portability, functions shall be defined with the `name () {…}` form
- since environment variables can be used by more than one template, all environment variables shall be used like follows:

  ```sh
  antigen theme "${ANTIGEN_THEME:-gentoo}"
  ```

  and hence, to be specific:

  - be named with _UPPERCASE_ characters
  - provide a default value, and override it only when needed
  - consider a value could have already been set/exported in another file

- for performance reasons, every setting and addition shall be configured in the single appropriate startup file in `$ZSHDOTDIR` (or what for it)

## Gotchas

- Due to a feature of a library used by [chezmoi], all custom variable names in the configuration file are converted to lowercase; see the [custom data fields appear as all lowercase strings] GitHub issue for more information.

- The [chezmoidata.format] data files are plain, and no templating is done on them; this means:

  - templates **cannot** be used in them
  - chezmoi **will not** generate them from templates

  due to this, they are a great way to store static data which is local to the executing host only

- The [chezmoi.format] data files are read **and merged** in alphabetical order (`json`, then `toml`, then finally `yaml`)

## TODO

> [] = to be done, `…` = in the workings, `?` = very low priority, `!` = high priority, `x` = will not do, `✓` = done

- `…` make indentation consistent
- `?` be able to use JSON files too
- `?` be able to use TOML files too

## Further readings

- [Chezmoi], [GNU stow] and [yadm]
- [ZSH and Bash startup files loading order]
- Chezmoi's [Custom data fields appear as all lowercase strings] GitHub issue
- [Sprig], an extension to go's [text/template] package

[gotchas]: #gotchas
[license]: LICENSE

[chezmoidata.format]: https://www.chezmoi.io/reference/special-files-and-directories/chezmoidata-format/
[encryption]: https://www.chezmoi.io/user-guide/encryption/

[chezmoi]: https://www.chezmoi.io/
[gnu stow]: https://www.gnu.org/software/stow/
[sprig]: https://masterminds.github.io/sprig/
[text/template]: https://pkg.go.dev/text/template
[yadm]: https://yadm.io/

[custom data fields appear as all lowercase strings]: https://github.com/twpayne/chezmoi/issues/463
[zsh and bash startup files loading order]: https://shreevatsa.wordpress.com/2008/03/30/zshbash-startup-files-loading-order-bashrc-zshrc-etc/
