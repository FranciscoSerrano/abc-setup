# Making Windows Terminal Pretty (Catppuccin Mocha + Nerd Font)

Your Ubuntu shell tools (Starship, Neovim, fastfetch) are already themed by the
setup script. But the **terminal window itself** — its colors and font — is drawn
by **Windows Terminal**, which lives on the Windows side. WSL can't safely edit it
for you, so here are the (quick!) manual steps.

You only do this once. Takes about 3 minutes.

---

## Step 1 — Install the JetBrainsMono Nerd Font on Windows

The setup script installs the font *inside* Linux, but Windows Terminal renders
text using **Windows** fonts. So it needs to be installed on Windows too.

1. Open File Explorer and go to:  `\\wsl$\Ubuntu\home\<your-username>\.local\share\fonts`
   (Replace `<your-username>` with your Linux username. Tip: run `whoami` in the terminal.)
2. Select all the `JetBrainsMono*.ttf` files.
3. Right-click → **Install** (or "Install for all users").

> Prefer downloading directly on Windows? Grab `JetBrainsMono.zip` from
> https://github.com/ryanoasis/nerd-fonts/releases/latest , unzip, select all
> `.ttf` files, right-click → Install.

---

## Step 2 — Add the Catppuccin Mocha color scheme

1. Open **Windows Terminal**.
2. Press `Ctrl + ,` to open Settings, then click **"Open JSON file"** in the
   bottom-left corner. This opens `settings.json`.
3. Find the `"schemes": [ ... ]` list. Paste this scheme object **inside** the
   square brackets (add a comma after it if other schemes follow):

```json
{
    "name": "Catppuccin Mocha",
    "background": "#1E1E2E",
    "foreground": "#CDD6F4",
    "cursorColor": "#F5E0DC",
    "selectionBackground": "#585B70",
    "black": "#45475A",
    "red": "#F38BA8",
    "green": "#A6E3A1",
    "yellow": "#F9E2AF",
    "blue": "#89B4FA",
    "purple": "#F5C2E7",
    "cyan": "#94E2D5",
    "white": "#BAC2DE",
    "brightBlack": "#585B70",
    "brightRed": "#F38BA8",
    "brightGreen": "#A6E3A1",
    "brightYellow": "#F9E2AF",
    "brightBlue": "#89B4FA",
    "brightPurple": "#F5C2E7",
    "brightCyan": "#94E2D5",
    "brightWhite": "#A6ADC8"
}
```

4. Save the file (`Ctrl + S`).

---

## Step 3 — Use the scheme + font for your Ubuntu profile

Still in Settings (the nice UI, not the JSON):

1. In the left sidebar, click your **Ubuntu** profile.
2. Go to **Appearance**.
3. Set **Color scheme** → **Catppuccin Mocha**.
4. Set **Font face** → **JetBrainsMono Nerd Font**.
5. Click **Save**.

Open a new Ubuntu tab and enjoy — you should see the fastfetch art in color,
a themed Starship prompt, and all the fancy icons rendering correctly. 🎉

---

### Troubleshooting
- **Icons look like boxes / question marks?** The Nerd Font isn't selected (Step 3.4)
  or isn't installed on Windows (Step 1).
- **Can't find the font in the dropdown?** Close and reopen Windows Terminal after
  installing the font.
