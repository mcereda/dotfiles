# Dotfiles

Personal dotfiles for better host management and more fun!

## License

The MIT license is used here, see [LICENSE].

## Status

Development is always ongoing. Changes will be made when I need them.

## Support

Aaahm… Well… Nope.

## Installation

It expects one to manage the repository as packages using [GNU stow]:

```shell
$ stow --target $target_dir --dotfiles $package_list

# simulate
$ stow --target $HOME --verbose common git linux vim zsh --dotfiles --simulate
…
LINK: .screenrc => Repositories/Private/dotfiles/screen/.screenrc
LINK: .vimrc => Repositories/Private/dotfiles/vim/.vimrc
WARNING: in simulation mode so not modifying filesystem.
```

## Usage

Most files are prefixed by numbers and managed the same way linux does with `/etc/profile` and `/etc/profile.d`:

1. the files are listed the default globbing behaviour in shells is to list files alphabetically
1. the files are sourced from the list above in FIFO style

```shell
$ tree -a zsh
zsh
├── .zshrc.d
│   ├── 00-home.env
│   ├── …
│   ├── 70-gcp-prompt.zsh
│   └── gitlab.zsh
├── .zshenv
└── .zshrc

$ cat zsh/.zshrc
…
for sh in ~/.zshrc.d/*
do
    [[ -r ${sh} ]] && source "${sh}"
done
unset sh
…
```

To achieve the expected result:

- environment variables should use default values, and override them only when needed:

   ```shell
   antigen theme ${ANTIGEN_THEME:-gentoo}
   ```

- the files' numbered prefix should follow a structured priority:

  1. generic environment customizations (_personal_, _work_, …)
  1. os-related overlays and customizations (_darwin_, _linux_, …)
  1. package managers customizations (`brew`, _macports_, …)
  1. frameworks configuration and activation (`antigen`, `zplug`, …)
  1. shell customization (`bash`, `zsh`, …)
  1. app overlays (`git`, `minikube`, …)
  1. aliases and functions
  1. prompt customization

This should ensure nice, subsequent overrides of variable values and settings.

I personally suggest to keep all shared resources in one place putting them under the `${package}/.local/share/${package}` folder and sourcing them inside a package's files:

```shell
$ tree -a zsh/.local/share/zsh
zsh/.local/share/zsh
└── zplug
    └── init.zsh

2 directories, 1 files

$ cat zsh/zshrc.d/zplug/9-init
source ${ZPLUG_HOME:-~/.local/share/zsh/zplug}/init.zsh
```

## Contributing

This repository is not open for contributions, but I might accept suggestions. Please use the repository's hosting platform's tools for this.

## Further readings

- [GNU stow]
- [antigen]

## Sources

- [Git submodules: adding, using, removing, updating]
- [ZSH and Bash startup files loading order]

[LICENSE]: LICENSE

[antigen]: https://github.com/zsh-users/antigen
[gnu stow]: https://www.gnu.org/software/stow

[git submodules: adding, using, removing, updating]: https://chrisjean.com/git-submodules-adding-using-removing-and-updating/
[zsh and bash startup files loading order]: https://shreevatsa.wordpress.com/2008/03/30/zshbash-startup-files-loading-order-bashrc-zshrc-etc/
