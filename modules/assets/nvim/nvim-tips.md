# Neovim Workflow & Navigation Tips

This guide covers the daily workflow and navigation shortcuts for your minimal Neovim configuration.

---

## 1. Project Navigation & Fuzzy Finding (Telescope)
The following shortcuts use your **Leader Key** (which is configured as `Space`).

| Shortcut | Action | Description | VS Code Equivalent |
|----------|--------|-------------|--------------------|
| `Space` + `f` + `f` | **Find Files** | Fuzzy search file names in the project | `Ctrl+P` |
| `Space` + `f` + `g` | **Live Grep** | Fuzzy search text inside all project files | `Ctrl+Shift+F` |
| `Space` + `f` + `b` | **Buffers** | Search list of currently open files | — |
| `Space` + `f` + `h` | **Help** | Search Neovim's built-in documentation | — |

*Tip: When inside a Telescope menu, press `Esc` to close it, or use `Ctrl+j`/`Ctrl+k` to navigate results.*

---

## 2. Directory Tree Exploration (`netrw`)
Neovim comes with a built-in file explorer. You don't need any plugins for this.

* Type `:Ex` (or `:Explore`) to open a full-screen directory tree.
* Type `:Vex` (Vertical Explore) to split the window and open the explorer on the left.
* **Basic Actions inside Explorer:**
  * `j` / `k` — Navigate up and down.
  * `Enter` — Open a file or enter a directory.
  * `ui` — Go up one level (parent directory).
  * `R` — Rename file/folder under cursor.
  * `D` — Delete file/folder under cursor.

---

## 3. Working with Open Files (Buffers)
In Neovim, files you open are called **buffers**.

* `:ls` — View a numbered list of all open buffers.
* `:b <part-of-filename>` — Jump to an open file by typing part of its name (e.g. `:b cli` will switch to `cli.nix`). Use `Tab` to autocomplete.
* **`Ctrl+^`** (or `Ctrl+6`) — Instantly toggle back and forth between your current file and the last active file. (Excellent for jumping between config and source files).
* `:bd` — Close (delete) the current buffer.

---

## 4. Screen Splits & Window Management
To split your screen and view files side-by-side:

* `:vs` (or `:vsplit`) — Split vertically.
* `:sp` (or `:split`) — Split horizontally.
* **`Ctrl+w` followed by `h` / `j` / `k` / `l`** — Move your cursor between the active split windows.
* `:q` (or `:x` / `:wq`) — Close the current window.

---

## 5. Nix Configuration Workflow
Since your configuration is managed by your Nix flake, follow these steps to modify Neovim:

1. Open and edit `/home/espdesign/git/nixos.den/modules/assets/nvim/init.lua`.
2. Apply changes to your profile:
   ```bash
   nix-apply
   ```
3. Open `nvim` and download any new plugins you added to the `vim.pack.add` block:
   ```vim
   :Pack install
   ```
4. Update existing plugins to their latest versions:
   ```vim
   :lua vim.pack.update()
   ```
5. Commit configuration changes in your Git repository:
   ```bash
   git add .
   git commit -m "chore: update neovim configuration"
   ```
