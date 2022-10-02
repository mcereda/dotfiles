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

> Tested on Fedora and Mac OS X.

1. install [chezmoi]
1. import the `age`/`gpg` key you might need to decrypt the encrypted files and give it ultimate trust
1. initialize `chezmoi` using this repository

   > just pick one, they are different mirrors of the same repository

   ```sh
   chezmoi init https://gitlab.com/mckie/dotfiles.git [--branch chezmoi]
   chezmoi init https://github.com/mcereda/dotfiles.git [--branch chezmoi]
   ```

   if no configuration file is already present on the host, this step will also create a default configuration file to enable encryption, which is needed by the template used in the next steps

1. optionally, create the [chezmoidata.format] data file in the repository root folder:

   ```yaml
   # file at $(chezmoi source-path)/.chezmoidata.yaml
   name: Johnny B. Good
   email: …
   ```

   values in here will be used to override the templates defaults; see [gotchas] for details

1. optionally, create a chezmoi configuration file specific to the host in a dedicated folder in `$hostsDir` (which defaults to `.hosts`), with the `.chezmoi.yaml` name:

   ```yaml
   # hostname is deepthought
   # file at $(chezmoi source-path)/.hosts/deepthought/.chezmoi.yaml
   encryption: gpg
   gpg: …
   ```

1. optionally, create an [encrypted][encryption] chezmoi configuration file specific to the destination in a dedicated folder with its hashed hostname in `$hostsDir` (which defaults to `.hosts`), with the name matching `encrypted_chezmoi.yaml.suffix`:

   ```plaintext
   -----BEGIN PGP MESSAGE-----
   Comment: hostname is deepthought
   Comment: get the hash with "chezmoi execute-template '{{ adler32sum (sha256sum .chezmoi.hostname) }}'"
   Comment: encrypt the file with "chezmoi encrypt" or the related encryption application's method
   Comment: file at $(chezmoi source-path)/.hosts/1092817333/encrypted_chezmoi.yaml.asc

   hQIMAwbYc…
   -----END PGP MESSAGE-----
   ```

1. re-run `chezmoi init` to create the comprehensive configuration file
1. check and apply the changes using chezmoi

   ```sh
   chezmoi diff
   chezmoi apply
   ```

The host-specific configuration files will merge with chezmoi's own configuration, and will be used by the templates.  
Encrypted host-specific configuration files will be decrypted and merged last, overwriting eventual values in the plaintext files.

## Design decisions

Due to less time in general, performance issues and the decision to not always do everything by myself:

- the files are managed using [chezmoi], just because it offers lots of features (templating and encryption, mostly) and I find it easier than [GNU stow] or other similar projects ([yadm])
- chezmoi's configuration files format of choice is **YAML**, because I find it is easy to read, write, and merge in the code
- files containing any private data shall be encrypted; see [encryption](#encryption) for details
- shell-related files shall focus on performance as I am easily annoied by slow prompts; see [shell files conventions](#shell-files-conventions) for details
- host-specific files are looked for in a directory named as the hostname, inside the `$hostsDir` directory:

  ```golang
  // file at $(chezmoi source-path)/dot_gitconfig
  {{- $hostsDir := dig "hostsdir" ".hosts" . }}
  {{- $hostGitConfigs := list (joinPath $hostsDir .chezmoi.hostname "dot_gitconfig") }}
  ```

  the `$hostsDir` variable can be manually defined using the `data.hostsDir` key in chezmoi's configuration:

  ```yaml
  # file at $HOME/.config/chezmoi/chezmoi.yaml
  data:
    hostsDir: …
  ```

### Encryption

The default [encryption] method of choice is `gpg`.

Some files are `decrypt`ed in the main templates and never used directly.  
Since those encrypted files are not registered in chezmoi, its `edit` command will **not** work transparently; use **something like** this instead:

```sh
chezmoi decrypt $HOME/.local/share/chezmoi/encrypted_file.yaml.asc --output /tmp/plaintext.yaml
vim /tmp/plaintext.yaml
chezmoi encrypt /tmp/plaintext.yaml --output $HOME/.local/share/chezmoi/encrypted_file.yaml.asc
rm /tmp/plaintext.yaml
```

Host-specific encrypted files are looked for in a directory named as the hashed hostname, inside the `$hostsDir` directory:

```golang
// file at $(chezmoi source-path)/dot_gitconfig
{{- $hashedHostname := dig "hashedhostname" (adler32sum (sha256sum .chezmoi.hostname)) . }}
{{- $hostEncryptedGitConfigs := list
        (joinPath $hostsDir $hashedHostname (print "encrypted_dot_gitconfig" (dig "age" "suffix" ".age" .)))
        (joinPath $hostsDir $hashedHostname (print "encrypted_dot_gitconfig" (dig "gpg" "suffix" ".asc" .))) }}
```

The hashed hostname can be manually defined using the `data.hashedHostname` key in chezmoi's configuration, and is included in the rendered configuration file after an init to speed things up on the next execution:

```yaml
# file at $HOME/.config/chezmoi/chezmoi.yaml
data:
  hashedhostname: …
```

By default, hostnames are hashed in 2 steps:

1. with `sha256sum` for relative security
1. with chezmoi's `adler32sum` to limit the output to a bunch of characters

and can be easily obtained with the following:

```sh
chezmoi execute-template '{{ adler32sum (sha256sum .chezmoi.hostname) }}'
```

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

- ~~Due to a feature of a library used by [chezmoi], all custom variable names in the configuration file are converted to lowercase; see the [custom data fields appear as all lowercase strings] GitHub issue for more information.~~ solved in [2376](https://github.com/twpayne/chezmoi/pull/2376/files)

- A value for `.encryption` **must** be set in chezmoi's configuration file **before execution** if the `decrypt` or `encrypt` functions are used in a template; this just sets a default application for encryption purposes, as the `decrypt` function will choose the appropriate application by itself.  
  The easiest solution to this is to leverage the available init functions to create a file with just that, and then re-run the 'init' step.

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

## Testing

```sh
dnf install -y https://github.com/twpayne/chezmoi/releases/download/v2.24.0/chezmoi-2.24.0-aarch64.rpm
```

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
