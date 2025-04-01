# 🧠 gsh — Shell-GPT Command Helper for Zsh

`gsh` is a minimalist Zsh function that uses OpenAI’s GPT API to suggest shell commands for your tasks. It gives you 3 ready-to-use commands, lets you pick the one you want, and copies it to your clipboard. Great for terminal workflows, scripting inspiration, or just avoiding Stack Overflow rabbit holes.

---

## ✨ Features

- ⚡ Uses GPT-4 to generate shell commands based on your query
- 🧠 Presents 3 interactive options
- 📋 Automatically copies the selected command to your clipboard (if `xclip` is available)
- 🗂 Caches previous responses (optional)
- ✅ Error-handling for API and parsing issues
- 🛠 Designed for simplicity — just one script, zero dependencies beyond `curl` and `python3` (or `jq`)
- 🧵 Works well with `fzf`-style workflows (not required)

---

## 🧰 Installation

### 1. Clone the repo

```bash
git clone https://github.com/dadams-AU/gsh-shellgpt ~/.config/zsh/plugins/gsh
```

### 2. Source it in your `.zshrc`

```zsh
source ~/.config/zsh/plugins/gsh/gsh.zsh
alias gsh="shellgpt"
```

Then reload your shell:
```bash
source ~/.zshrc
```

---

## 🔐 Setup OpenAI API Key

You’ll need an OpenAI API key with access to GPT-4. Add this to your environment:

```bash
export OPENAI_API_KEY="sk-..."
```

To set it permanently, add that line to your `~/.zshenv`, `~/.zprofile`, or `~/.config/zsh/env.zsh`.

---

## 🧪 Usage

Just type a natural-language request:

```bash
gsh find all .bib files in my home directory without sudo
```

You’ll get:

```
🧠 Available Commands:

1. `find ~/ -type f -name "*.bib"`
2. ...
3. ...

Enter command number (1–3) or q to quit:
```

Select a number, and the command will be printed and copied to your clipboard (if `xclip` is installed). Otherwise, you can copy/paste manually.

---

## 🔧 Options and Customization

You can tweak the model or default behavior by modifying `gsh.zsh`:

- Change the model (e.g., to `gpt-4-turbo`)
- Redirect or store cache/history
- Integrate with `fzf` for fuzzy selection

---

## 📦 Optional: Clipboard Support

This tool uses `xclip` for Linux clipboard copying. You can install it with:

```bash
sudo apt install xclip  # Debian/Ubuntu
sudo pacman -S xclip    # Arch
```

On macOS, replace `xclip` logic with `pbcopy`.

---

## 🧩 Integrate with a Plugin Manager

If you’re using a Zsh plugin manager like [zinit](https://github.com/zdharma-continuum/zinit) or [antidote](https://getantidote.github.io/), you can load `gsh.zsh` directly.

Example (zinit):

```zsh
zinit light YOUR_USERNAME/gsh-shellgpt
```

---

## 🧼 Uninstall

Just remove the `source` line and alias from `.zshrc`, then delete the plugin directory:

```bash
rm -rf ~/.config/zsh/plugins/gsh
```

---

## 🪪 License

MIT License. Feel free to fork, improve, and share.

