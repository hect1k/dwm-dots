# Enable colors
autoload -U colors && colors

# Function to display Git branch & status with conditional spacing
git_info() {
  local branch git_status
  branch=$(git symbolic-ref --short HEAD 2>/dev/null || git describe --tags --exact-match 2>/dev/null)

  if [[ -n $branch ]]; then
    # Get Git status indicators
    local staged unstaged untracked
    staged=$(git diff --cached --quiet || echo "+")      # Staged changes
    unstaged=$(git diff --quiet || echo "!")            # Unstaged changes
    untracked=$(git ls-files --others --exclude-standard | grep -q . && echo "?")  # Untracked files

    git_status="${staged}${unstaged}${untracked}"
    
    # Add space only if there is a git status
    [[ -n $git_status ]] && git_status=" $git_status"

    echo " %{$fg_bold[yellow]%}$branch%{$fg_bold[red]%}$git_status"
  fi
}

# Bold Zsh Prompt
setopt PROMPT_SUBST
PS1="%B%{$fg_bold[red]%}[%{$fg_bold[yellow]%}%n%{$fg_bold[green]%}@%{$fg_bold[blue]%}%M %{$fg_bold[magenta]%}%~$(git_info)%{$fg_bold[red]%}]%{$reset_color%}$%b "

# History settings
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.cache/zsh/history
setopt hist_ignore_all_dups   # Ignore duplicate commands
setopt hist_verify            # Verify history before running

# Auto/tab complete optimizations
autoload -U compinit && compinit -C
zstyle ':completion:*' menu select
zmodload zsh/complist
_comp_options+=(globdots)   # Include hidden files

# Vi mode
bindkey -v
export KEYTIMEOUT=1

# Vim-like navigation in tab completion menu
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char

# Change cursor shape for different vi modes
function zle-keymap-select {
  case "$KEYMAP" in
    vicmd) echo -ne '\e[1 q' ;;   # Block cursor in normal mode
    viins|main|'') echo -ne '\e[5 q' ;; # Beam cursor in insert mode
  esac
}
zle -N zle-keymap-select
zle-line-init() { zle -K viins; echo -ne "\e[5 q"; }
zle -N zle-line-init
echo -ne '\e[5 q' # Set beam cursor on startup
preexec() { echo -ne '\e[5 q'; } # Reset cursor on each new command

# Use lf to switch directories with Ctrl+O
lfcd() {
    local dir
    dir=$(mktemp) && lf -last-dir-path="$dir" "$@" && cd "$(cat "$dir")" 2>/dev/null && rm -f "$dir"
}
bindkey -s '^o' 'lfcd\n'

# Edit command in Vim with Ctrl+E
autoload edit-command-line && zle -N edit-command-line
bindkey '^e' edit-command-line

# Load custom aliases and shortcuts
[[ -f "$HOME/.config/shortcutrc" ]] && source "$HOME/.config/shortcutrc"
[[ -f "$HOME/.config/aliasrc" ]] && source "$HOME/.config/aliasrc"

# Enable syntax highlighting (should be last)
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null

# Start X on tty1 if no display
[[ -z $DISPLAY && $(tty) = /dev/tty1 ]] && exec startx

# Environment variables
export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PNPM_HOME:$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

# Auto change to directory if command is a folder
setopt autocd

# Aliases
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias gc='git clone --depth=1'
alias bc='better-commits'
alias pn='pocketnaut'
alias v='nvim'
alias vi='nvim'
alias vim='nvim'

# Load fzf with zsh integration
source <(fzf --zsh)

# Load fzf keybindings and completion
if [[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]]; then
  source /usr/share/doc/fzf/examples/key-bindings.zsh
fi
if [[ -f /usr/share/doc/fzf/examples/completion.zsh ]]; then
  source /usr/share/doc/fzf/examples/completion.zsh
fi
