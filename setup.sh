#!/usr/bin/env bash
# =====================================================================
#  Allyson's WSL / Ubuntu dev-environment setup
#  ---------------------------------------------------------------------
#  Installs: JetBrainsMono Nerd Font, Starship prompt, Neovim (latest),
#            fastfetch, and the toolchains for JS / Go / Racket LSPs.
#  Also drops in themed configs (Catppuccin Mocha) for Neovim, Starship
#  and fastfetch, and runs fastfetch in every new terminal.
#
#  SAFE TO RE-RUN: it skips things that are already installed and backs
#  up any config it would overwrite into ~/.config-backup-<timestamp>/.
#
#  Usage:   bash setup.sh
# =====================================================================

set -euo pipefail  # stop on errors, undefined vars, and failed pipes

# ----- pretty logging helpers ----------------------------------------
c_reset="\033[0m"; c_blue="\033[1;34m"; c_green="\033[1;32m"; c_yellow="\033[1;33m"
info()  { echo -e "${c_blue}==>${c_reset} $*"; }
ok()    { echo -e "${c_green} ✓${c_reset} $*"; }
warn()  { echo -e "${c_yellow} !${c_reset} $*"; }

# Where THIS script lives, so we can find the config/ folder next to it.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_SRC="$SCRIPT_DIR/config"

# One backup folder per run, created only if we actually need to move a file.
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
backup_if_exists() {
  # $1 = path that we're about to overwrite
  if [ -e "$1" ] || [ -L "$1" ]; then
    mkdir -p "$BACKUP_DIR"
    mv "$1" "$BACKUP_DIR/"
    warn "Backed up existing $(basename "$1") -> $BACKUP_DIR/"
  fi
}

# True if a command exists on PATH (used to skip already-installed tools).
have() { command -v "$1" >/dev/null 2>&1; }

echo
info "Starting setup. This may take a few minutes on first run."
echo

# ---------------------------------------------------------------------
# 0. Base packages we rely on later (git, curl, unzip, build tools).
# ---------------------------------------------------------------------
info "Updating apt and installing base tools (git, curl, unzip, build-essential)..."
sudo apt-get update -y
sudo apt-get install -y git curl unzip wget build-essential ca-certificates fontconfig
ok "Base tools ready."

# ---------------------------------------------------------------------
# 1. JetBrainsMono Nerd Font (installed into the Linux side).
#    NOTE: Windows Terminal draws text with Windows fonts, so this also
#    needs installing on Windows -- see config/WINDOWS-TERMINAL.md.
# ---------------------------------------------------------------------
FONT_DIR="$HOME/.local/share/fonts"
if ls "$FONT_DIR"/JetBrainsMono*.ttf >/dev/null 2>&1; then
  ok "JetBrainsMono Nerd Font already installed. Skipping."
else
  info "Installing JetBrainsMono Nerd Font..."
  mkdir -p "$FONT_DIR"
  tmp_zip="$(mktemp -d)/JetBrainsMono.zip"
  curl -fL -o "$tmp_zip" \
    "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
  unzip -o "$tmp_zip" -d "$FONT_DIR" >/dev/null
  fc-cache -f "$FONT_DIR" >/dev/null
  ok "Nerd Font installed to $FONT_DIR"
fi

# ---------------------------------------------------------------------
# 2. Starship prompt.
# ---------------------------------------------------------------------
if have starship; then
  ok "Starship already installed. Skipping."
else
  info "Installing Starship prompt..."
  curl -fsSL https://starship.rs/install.sh | sh -s -- --yes
  ok "Starship installed."
fi

# ---------------------------------------------------------------------
# 3. Neovim (latest stable). Ubuntu's apt version is too old for modern
#    LSP plugins, so we grab the official release tarball into /opt.
# ---------------------------------------------------------------------
if have nvim && nvim --version | head -1 | grep -qE 'v0\.(9|1[0-9])'; then
  ok "A recent Neovim is already installed. Skipping."
else
  info "Installing latest stable Neovim..."
  nvim_tgz="$(mktemp -d)/nvim.tar.gz"
  # linux-x86_64 is the right build for WSL on a normal PC.
  curl -fL -o "$nvim_tgz" \
    "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz"
  sudo rm -rf /opt/nvim
  sudo mkdir -p /opt/nvim
  sudo tar -C /opt/nvim --strip-components=1 -xzf "$nvim_tgz"
  sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim
  ok "Neovim installed: $(nvim --version | head -1)"
fi

# ---------------------------------------------------------------------
# 4. fastfetch.
# ---------------------------------------------------------------------
if have fastfetch; then
  ok "fastfetch already installed. Skipping."
else
  info "Installing fastfetch..."
  # Try the official PPA first (nice for updates); fall back to the .deb.
  if sudo add-apt-repository -y ppa:zhangsongcui3371/fastfetch 2>/dev/null; then
    sudo apt-get update -y
    sudo apt-get install -y fastfetch
  else
    warn "PPA unavailable, installing the official .deb instead..."
    deb="$(mktemp -d)/fastfetch.deb"
    curl -fL -o "$deb" \
      "https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-linux-amd64.deb"
    sudo apt-get install -y "$deb"
  fi
  ok "fastfetch installed."
fi

# ---------------------------------------------------------------------
# 5. Language toolchains (so the LSP servers actually have something to
#    talk to). JavaScript -> Node.js, Go -> go, Racket -> racket.
# ---------------------------------------------------------------------

# ---- Node.js (via NodeSource, gives a modern LTS) ----
if have node; then
  ok "Node.js already installed ($(node --version)). Skipping."
else
  info "Installing Node.js (LTS) for the JavaScript LSP..."
  curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
  sudo apt-get install -y nodejs
  ok "Node.js installed ($(node --version))."
fi

# ---- Go (official tarball into /usr/local) ----
if have go; then
  ok "Go already installed ($(go version)). Skipping."
else
  info "Installing Go for the Go LSP (gopls)..."
  GO_VER="1.22.5"   # bump this to update Go later
  go_tgz="$(mktemp -d)/go.tar.gz"
  curl -fL -o "$go_tgz" "https://go.dev/dl/go${GO_VER}.linux-amd64.tar.gz"
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf "$go_tgz"
  ok "Go installed."
fi

# ---- Racket + its language server ----
if have racket; then
  ok "Racket already installed. Skipping install."
else
  info "Installing Racket..."
  sudo apt-get install -y racket
  ok "Racket installed."
fi
# racket-langserver is what Neovim's LSP talks to. `raco` ships with Racket.
if have raco; then
  if raco pkg show racket-langserver >/dev/null 2>&1; then
    ok "racket-langserver already installed. Skipping."
  else
    info "Installing racket-langserver (Racket LSP)..."
    raco pkg install --auto --scope user racket-langserver
    ok "racket-langserver installed."
  fi
fi

# ---------------------------------------------------------------------
# 6. Drop in the config files (backing up anything already there).
# ---------------------------------------------------------------------
info "Installing config files..."

# Neovim config -> ~/.config/nvim/init.lua
mkdir -p "$HOME/.config/nvim"
backup_if_exists "$HOME/.config/nvim/init.lua"
cp "$CONFIG_SRC/nvim/init.lua" "$HOME/.config/nvim/init.lua"
ok "Neovim config installed."

# fastfetch config + ascii art -> ~/.config/fastfetch/
mkdir -p "$HOME/.config/fastfetch"
backup_if_exists "$HOME/.config/fastfetch/config.jsonc"
backup_if_exists "$HOME/.config/fastfetch/ascii.txt"
cp "$CONFIG_SRC/fastfetch/config.jsonc" "$HOME/.config/fastfetch/config.jsonc"
cp "$CONFIG_SRC/fastfetch/ascii.txt"    "$HOME/.config/fastfetch/ascii.txt"
ok "fastfetch config installed."

# Starship config -> ~/.config/starship.toml
mkdir -p "$HOME/.config"
backup_if_exists "$HOME/.config/starship.toml"
cp "$CONFIG_SRC/starship.toml" "$HOME/.config/starship.toml"
ok "Starship config installed."

# ---------------------------------------------------------------------
# 7. Wire everything into the correct shell startup file (idempotently).
#    Ubuntu defaults to bash, but the user may be on zsh -- detect the
#    LOGIN shell and configure the matching rc file, with the right init
#    syntax for each shell. Adds one clearly-marked block, only once.
# ---------------------------------------------------------------------

# Determine the login shell. $SHELL is the user's default shell; fall
# back to reading /etc/passwd in case $SHELL isn't set.
LOGIN_SHELL="$(basename "${SHELL:-$(getent passwd "$USER" | cut -d: -f7)}")"

case "$LOGIN_SHELL" in
  zsh)
    RC_FILE="$HOME/.zshrc"
    STARSHIP_INIT='eval "$(starship init zsh)"'
    # zsh's own way to test for an interactive shell.
    FASTFETCH_GUARD='[[ -o interactive ]] && command -v fastfetch >/dev/null && fastfetch'
    ;;
  bash)
    RC_FILE="$HOME/.bashrc"
    STARSHIP_INIT='eval "$(starship init bash)"'
    # bash: $- contains "i" when interactive.
    FASTFETCH_GUARD='case $- in *i*) command -v fastfetch >/dev/null && fastfetch ;; esac'
    ;;
  *)
    # Unknown shell -- default to bash and print a notice.
    warn "Unrecognized shell '$LOGIN_SHELL'; configuring ~/.bashrc as a fallback."
    RC_FILE="$HOME/.bashrc"
    STARSHIP_INIT='eval "$(starship init bash)"'
    FASTFETCH_GUARD='case $- in *i*) command -v fastfetch >/dev/null && fastfetch ;; esac'
    ;;
esac

info "Detected shell: $LOGIN_SHELL -> configuring $(basename "$RC_FILE")"

MARKER="# >>> allyson-wsl-setup >>>"
if grep -qF "$MARKER" "$RC_FILE" 2>/dev/null; then
  ok "$(basename "$RC_FILE") already configured. Skipping."
else
  info "Adding startup lines to $(basename "$RC_FILE")..."
  # Note: this heredoc is UNQUOTED so $STARSHIP_INIT / $FASTFETCH_GUARD
  # expand now. The PATH line is escaped (\$) so it stays literal and is
  # evaluated later, every time the shell starts.
  cat >> "$RC_FILE" <<EOF

# >>> allyson-wsl-setup >>>
# (Added by setup.sh. This block can be edited or removed.)

# Make Go and locally-installed tools available on PATH.
export PATH="\$PATH:/usr/local/go/bin:\$HOME/go/bin:\$HOME/.local/bin"

# Start the Starship prompt.
$STARSHIP_INIT

# Run fastfetch when a new interactive terminal opens.
$FASTFETCH_GUARD
# <<< allyson-wsl-setup <<<
EOF
  ok "$(basename "$RC_FILE") updated."
fi

# ---------------------------------------------------------------------
# 8. Done -- final instructions.
# ---------------------------------------------------------------------
echo
ok "All done! 🎉"
echo
info "Two quick things to finish up:"
echo "   1. Close this terminal and open a NEW one (so everything loads)."
echo "      The first time you open Neovim (\`nvim\`), it will auto-install"
echo "      its plugins -- give it a few seconds, then quit and reopen."
echo
echo "   2. Theme the terminal window itself (colors + font) by following:"
echo "      $CONFIG_SRC/WINDOWS-TERMINAL.md"
echo
warn "If a Nerd Font icon looks like a box, you still need to install the"
warn "font on the WINDOWS side and select it -- see WINDOWS-TERMINAL.md."
echo
