# macOS Setup with nix-darwin

This repository contains my personal `nix-darwin` setup for managing macOS system settings, packages, and applications declaratively using Nix, using [ryan4yin/nix-darwin-kickstarter](https://github.com/ryan4yin/nix-darwin-kickstarter) as a foundation.

## Repository Structure

```
.
├── flake.nix                 # Main flake configuration
├── flake.lock                # Flake dependency lock file
├── Makefile                  # Build commands
├── modules/                  # System-level modules
│   ├── nix-core.nix         # Nix daemon and flake settings
│   ├── system.nix           # macOS system preferences
│   ├── apps.nix             # Homebrew and system packages
│   └── host-users.nix       # Host and user configuration
├── home/                     # User-level home-manager modules
│   ├── default.nix          # Home-manager entry point
│   ├── core.nix             # Core packages and programs
│   ├── git.nix              # Git configuration
│   ├── shell.nix            # Zsh shell configuration
│   └── tmux.conf            # Tmux configuration
└── scripts/                  # Helper scripts
    ├── brew_no_quarantine.sh        # Remove quarantine from Chromium
    ├── alacritty_theme_monitor.sh   # Monitor system appearance changes
    └── alacritty_theme_switcher.sh  # Switch Alacritty theme
```

## Table of Contents

- [Installation](#installation)
- [Post-Installation](#post-installation)
- [Manual Configuration](#manual-configuration)
- [Resources](#resources)

---

## Installation

### Step 1: Install Nix with Flakes Support

Follow the installation instructions from the official [nix-darwin repository](https://github.com/nix-darwin/nix-darwin).

### Step 2: Clone This Repository

```bash
# Clone to a location of your choice
git clone https://github.com/jp-roisin/nix-darwin ~/etc/nix-darwin
cd ~/etc/nix-darwin
```

### Step 3: Update Personal Information

Edit `flake.nix` and update these values:

```nix
username = "jp";  # Change to your username
useremail = "your-email@example.com";  # Change to your email
hostname = "macbook";  # Change if desired
```

### Step 4: Build and Apply Configuration

```bash
sudo make build
```

This command will:
1. Build the nix-darwin configuration
2. Switch to the new configuration
3. Install Homebrew packages and applications
4. Apply system settings
5. Remove quarantine from Chromium

**Note:** The first build will take 15-30 minutes as it downloads and installs everything.

### Step 5: Restart Your Mac

```bash
sudo shutdown -r now
```

---

## Post-Installation

_TODO: Document what's automatically configured after installation_

---

## Manual Configuration

### Development Setup

<details>
<summary><strong>Development Tools & Credentials</strong></summary>

- [ ] **SSH Keys**
  - [ ] Generate new SSH key: `ssh-keygen -t ed25519 -C "your-email@example.com"`
  - [ ] Add to ssh-agent: `ssh-add --apple-use-keychain ~/.ssh/id_ed25519`
  - [ ] Add public key to GitHub/GitLab/Bitbucket

- [ ] **GPG Keys**
  - [ ] Import GPG keys for git commit signing
  - [ ] Configure git: `git config --global user.signingkey <key-id>`
  - [ ] Configure git: `git config --global commit.gpgsign true`

- [ ] **GitHub CLI**
  - [ ] Install: `brew install gh`
  - [ ] Authenticate: `gh auth login`

- [ ] **Rust**
  - [ ] Run: `rustup-init` to complete Rust installation

- [ ] **Mise**
  - [ ] Configure Node.js: `mise use --global node@lts`
  - [ ] Configure Python: `mise use --global python@latest`
  - [ ] Install other runtimes as needed

- [ ] **PostgreSQL**
  - [ ] Start service: `brew services start postgresql@17`
  - [ ] Create database user if needed

- [ ] **Redis**
  - [ ] Start service: `brew services start redis`

- [ ] **Docker**
  - [ ] Sign in to Docker Hub
  - [ ] Configure Docker resources (Settings → Resources)

- [ ] **IDE Configuration**
  - [ ] WebStorm: Sign in to JetBrains account, sync settings
  - [ ] VS Code: Sign in to sync settings and extensions
  - [ ] Configure language server settings

- [ ] **API Keys & Environment Variables**
  - [ ] Create `~/.zshenv` or `~/.env` for sensitive variables
  - [ ] Add API keys for services you use

</details>

<details>
<summary><strong>Terminal & Shell</strong></summary>

- [ ] **Alacritty**
  - [ ] Install themes: `mkdir -p ~/.config/alacritty/themes && git clone https://github.com/alacritty/alacritty-theme ~/.config/alacritty/themes`
  - [ ] Verify theme auto-switching works (change system appearance)

- [ ] **Tmux**
  - [ ] Install TPM (Tmux Plugin Manager): `git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm`
  - [ ] Install plugins: Open tmux, press `Ctrl-Space + I`

- [ ] **Zsh**
  - [ ] Verify autojump works: `j <directory>` after visiting directories
  - [ ] Add any custom aliases to `home/shell.nix`

- [ ] **Neovim**
  - [ ] Install your preferred Neovim config (LazyVim, NvChad, etc.)
  - [ ] Or clone your dotfiles: `git clone <your-nvim-config> ~/.config/nvim`

</details>

### Applications & Services

<details>
<summary><strong>Communication & Social</strong></summary>

- [ ] **Signal**
  - [ ] Link to phone

- [ ] **WhatsApp**
  - [ ] Scan QR code to link

- [ ] **Discord**
  - [ ] Sign in to account

- [ ] **Microsoft Teams**
  - [ ] Sign in with work account

</details>

<details>
<summary><strong>Productivity</strong></summary>

- [ ] **Alfred**
  - [ ] Purchase/enter Powerpack license
  - [ ] Configure hotkey (default: Cmd+Space, may need to disable Spotlight)
  - [ ] Sync preferences if using cloud storage
  - [ ] Install workflows

- [ ] **Logseq**
  - [ ] Choose graph location
  - [ ] Configure sync (iCloud, Syncthing, etc.)

- [ ] **Anki**
  - [ ] Sign in to AnkiWeb
  - [ ] Sync decks

</details>

<details>
<summary><strong>Media & Entertainment</strong></summary>

- [ ] **Spotify**
  - [ ] Sign in to account
  - [ ] Download offline playlists if needed

- [ ] **Jellyfin Media Player**
  - [ ] Connect to Jellyfin server

</details>

<details>
<summary><strong>Utilities & System</strong></summary>

- [ ] **Tailscale**
  - [ ] Sign in and connect to network

- [ ] **Stats**
  - [ ] Configure menu bar widgets
  - [ ] Grant necessary permissions

- [ ] **AeroSpace**
  - [ ] Configure keybindings: `~/.aerospace.toml`
  - [ ] Grant Accessibility permissions (System Settings → Privacy & Security → Accessibility)

- [ ] **Borders** (FelixKratz)
  - [ ] Start service: `brew services start borders`
  - [ ] Configure if needed

</details>

### System Settings

<details>
<summary><strong>macOS Settings Not Managed by Nix</strong></summary>

- [ ] **System Settings → Privacy & Security**
  - [ ] Grant Full Disk Access to Terminal/Alacritty
  - [ ] Grant Accessibility access to AeroSpace
  - [ ] Review and configure other app permissions

- [ ] **System Settings → Keyboard**
  - [ ] Configure additional keyboard shortcuts if needed
  - [ ] Set up text replacements

- [ ] **System Settings → Desktop & Dock**
  - [ ] Add/remove apps from Dock
  - [ ] Configure Hot Corners if desired

- [ ] **System Settings → Displays**
  - [ ] Arrange multiple displays
  - [ ] Set resolution/scaling preferences

- [ ] **System Settings → Trackpad**
  - [ ] Verify tap to click is enabled
  - [ ] Adjust tracking speed

- [ ] **System Settings → Sound**
  - [ ] Configure input/output devices
  - [ ] Adjust alert volume

- [ ] **System Settings → Sharing**
  - [ ] Set Computer Name
  - [ ] Enable/disable sharing services

- [ ] **System Settings → Users & Groups**
  - [ ] Set profile picture

- [ ] **Safari** (if using)
  - [ ] Configure default browser
  - [ ] Import bookmarks

- [ ] **Time Machine**
  - [ ] Set up backup disk
  - [ ] Configure backup schedule

</details>

### Optional & Custom

<details>
<summary><strong>Additional Manual Tasks</strong></summary>

- [ ] _Add your custom tasks here_
- [ ] 
- [ ] 
- [ ] 

</details>

---

## Resources

- [nix-darwin manual](https://daiderd.com/nix-darwin/manual/index.html)
- [home-manager manual](https://nix-community.github.io/home-manager/)
- [Nix language documentation](https://nixos.org/manual/nix/stable/language/)
- [NixOS and Flakes Book](https://github.com/ryan4yin/nixos-and-flakes-book)
- [macOS defaults reference](https://github.com/yannbertrand/macos-defaults)
