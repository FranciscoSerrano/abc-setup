# WSL Dev Environment Setup 🐧✨

A one-command setup that turns a plain Ubuntu-on-WSL install into a pretty,
comfortable place to learn Linux and code. Themed with **Catppuccin Mocha**
throughout.

## What it sets up

- 🔤 **JetBrainsMono Nerd Font** (for icons in the prompt and fastfetch)
- 🚀 **Starship** prompt, themed Catppuccin Mocha
- 📝 **Neovim** (latest stable) with a small, well-commented config:
  - Line numbers + relative line numbers
  - Syntax highlighting (Treesitter)
  - LSP (autocomplete, go-to-definition, errors) for **JavaScript**, **Go**, and **Racket**
- 🖼️ **fastfetch** that greets you in every new terminal, using the included art
- 🧰 Language toolchains: **Node.js**, **Go**, and **Racket** (so the LSPs work)

The script is **safe to re-run** — it skips anything already installed and backs
up any config it would replace into `~/.config-backup-<timestamp>/`. It also
detects whether your shell is **bash or zsh** and configures the right startup
file (`~/.bashrc` or `~/.zshrc`) automatically.

## How to use it

Open your Ubuntu (WSL) terminal and run:

```bash
git clone https://github.com/FranciscoSerrano/abc-setup.git
cd abc-setup
./setup.sh
```

It'll ask for your password once or twice (that's `sudo` installing packages —
totally normal).

> If you see `permission denied`, run `bash setup.sh` instead (or
> `chmod +x setup.sh` once, then `./setup.sh`).

## After it finishes — 2 steps

1. **Close the terminal and open a new one.** The first time you run `nvim`,
   it downloads its plugins automatically — wait a few seconds, then quit
   (`:q`) and reopen.
2. **Make the terminal window itself pretty** (its colors + font) by following
   [`config/WINDOWS-TERMINAL.md`](config/WINDOWS-TERMINAL.md). This part can't
   be automated because Windows Terminal's settings live on the Windows side.

## Editing things yourself

Everything is meant to be tinkered with — the config files are commented:

| What | Where |
|------|-------|
| Neovim | `~/.config/nvim/init.lua` |
| Starship prompt | `~/.config/starship.toml` |
| fastfetch | `~/.config/fastfetch/config.jsonc` |
| Terminal font/colors | see `config/WINDOWS-TERMINAL.md` |

## Neovim quick-start

| Do this | Keys |
|---------|------|
| Save | `:w` |
| Quit | `:q` (force: `:q!`) |
| Open a file | `:e path/to/file` |
| Go to definition | `gd` |
| Show docs | `K` |
| Rename a symbol | `Space` then `rn` |
| See LSP server status | `:Mason` |
| Diagnose problems | `:checkhealth` |

## Notes / assumptions

- Built for **x86_64** (a normal Intel/AMD PC — the usual case for WSL).
  On an ARM machine, the download URLs in `setup.sh` need the `arm64` variants.
- Designed for **Ubuntu/Debian** (uses `apt`).
