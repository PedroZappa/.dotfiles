 ###############
 ### General ###
 ###############
 
 # Correct wrong spellings
 setopt correct
 
 # Load colors
 autoload -U colors && colors
 for COLOR in RED GREEN YELLOW BLUE MAGENTA CYAN BLACK WHITE; do
    eval $COLOR='$fg_no_bold[${(L)COLOR}]'
    eval BOLD_$COLOR='$fg_bold[${(L)COLOR}]'
 done
 eval NC='$reset_color'
 
 ##################
 ### Completion ###
 ##################
 
 # Load and initialise completion system
 autoload -Uz compinit
 zstyle ':completion:*' menu select
 zmodload zsh/complist
 compinit -d "$XDG_CACHE_HOME/zsh/.zshcompdump-$ZSH_VERSION"
 _comp_options+=(globdots)
 
 ##########################
 ### Zap Plugin Manager ###
 ##########################
 
 [ -f "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh" ] && source "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh"
 plug "zsh-users/zsh-autosuggestions"
 plug "zap-zsh/supercharge"
 plug "zsh-users/zsh-syntax-highlighting"
 plug "hlissner/zsh-autopair"
 plug "zsh-users/zsh-history-substring-search"
 plug "MichaelAquilina/zsh-you-should-use"
 plug "zap-zsh/completions"
 plug "zap-zsh/sudo"
 plug "web-search"
 plug "zap-zsh/fzf"
 plug "zap-zsh/web-search"
 plug "jeffreytse/zsh-vi-mode"
 
 #######################
 ### Zedro's Scripts ###
 #######################
 
 # tmux
 alias zmux=~/.dotfiles/scripts/tmux/zmux-init.sh
 alias xmux=~/.dotfiles/scripts/tmux/zmux-kill.sh
 
 # Screen Recording
 # kill simplescreenrecorder
 alias kill-screenrec=~/.dotfiles/scripts/i3/kill-screenrec.sh
 
 # lulz
 alias greet=~/.dotfiles/scripts/zsh/zsh-greet.sh
 alias zshcow=~/.dotfiles/scripts/zsh/cowsay-fortune.sh
 
 #################
 ### Greetings ###
 #################
 
 greet $HOST
 
 #############
 ### Enoji ###
 #############

zemoji() {
    # Navigate to the project directory
    cd ~/.dotfiles/scripts/zemoji/ || return
    # Run the make command to set up the virtual environment and database
    make
    # Activate the virtual environment
    source .venv/bin/activate
    # Execute the Python script
    python app.py
    # Deactivate the virtual environment after the script completes
    deactivate
}

################
### Keyboard ###
################

# eval "setxkbmap us"

#######################
### Zedro's Aliases ###
#######################

# Compiling
alias ccw='cc -Wall -Wextra -Werror -g'

# 42 Norm Check
alias nn='norminette'

# Neovim
alias v='nvim'
alias vc='vim | lolcat'
alias clear_nvim='rm -rf ~/.local/share/nvim'
 
# git
alias ga='git add'
alias gap='git add -p'
alias gst='git status'
alias gc='git commit -m'
alias gp='git push'
alias gl='git pull'
alias gls='git pull && git submodule update --recursive --progress'
alias gco='git checkout'
alias gcb='git checkout -b'
alias glgg='git log --graph --oneline --decorate'
alias glgs='git log --graph --oneline --decorate | head -n 7'
alias gm='git merge --stat --log'

# Glow Markdown Renderer
alias glow=~/bin/glow/glow

alias obsidian='~/.local/share/AppImage/Obsidian-1.7.7.AppImage --no-sandbox'
alias ghostty='~/.local/bin/ghostty.AppImage'

# Audio
# Send / Read Streams
alias sstream="~/.dotfiles/scripts/audio/send-stream.sh"
alias rstream="~/.dotfiles/scripts/audio/read-stream.sh"
 
 # File system Navigation
 # cd || zoxide
 if command -v zoxide > /dev/null 2>&1; then
 	eval "$(zoxide init --cmd cd zsh)"
 	echo "[Running ${GREEN}zoxide${NC}! 📂]"
 else 
 	echo "[Running ${YELLOW}cd${NC}! 📂]"
 fi
 # ls || eza
 if command -v eza > /dev/null 2>&1; then
 	echo "[Running ${GREEN}eza${NC}! 📊]"
 	alias ls='eza'
 	alias ll='ls -al'
 	alias llx='eza -laZ --total-size'
 	alias llg='eza -laZ --total-size --git --git-repos'
 else
 	echo "[Running ${YELLOW}ls${NC}! ]"
 	alias ll='ls -al --color'
 fi
 
 # Load Cowsay
 if command -v lolcat > /dev/null 2>&1; then
 	eval "zshcow" | lolcat
 else
 	eval "zshcow"
 fi
 
 ############################
 ### Load Starship Prompt ###
 ############################
 
 if command -v starship > /dev/null 2>&1; then
     eval "$(starship init zsh)"
 else
     ZSH_THEME="refined"
 fi
 
 #####################################
 ### Clear google-chrome Singleton* ###
 #####################################
 if [[ $USER == "passunca" ]]; then
   rm -rf ~/.config/google-chrome/Singleton*
 fi
 
 eval "$(atuin init zsh)"
 
 # Set up fzf key bindings and fuzzy completion
 # Define a function to run fzf
 fzf-file-widget() {
   LBUFFER="${LBUFFER}$(fzf)"
   local ret=$?
   zle reset-prompt
   return $ret
 }
 
 # Create a ZLE widget for the function
 zle -N fzf-file-widget
 
 # Bind the widget to a key combination (e.g., Ctrl+F)
 bindkey '^F' fzf-file-widget
 
 source <(fzf --zsh)
 # Set up fzf key bindings and fuzzy completion
 # source /usr/share/doc/fzf/examples/key-bindings.zsh
 # source /usr/share/doc/fzf/examples/completion.zsh

. "$HOME/.local/share/../bin/env"
