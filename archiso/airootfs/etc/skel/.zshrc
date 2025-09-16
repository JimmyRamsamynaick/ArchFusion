# ArchFusion OS - Configuration Zsh
# Configuration moderne et optimisée

# Historique
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory
setopt sharehistory
setopt incappendhistory
setopt histignoredups
setopt histignorespace

# Options Zsh
setopt autocd
setopt correct
setopt nomatch
setopt notify
setopt promptsubst

# Complétion
autoload -Uz compinit
compinit

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

# Couleurs
autoload -U colors && colors

# Prompt personnalisé ArchFusion
PROMPT='%{$fg[cyan]%}┌─[%{$fg[green]%}%n%{$fg[cyan]%}@%{$fg[blue]%}archfusion%{$fg[cyan]%}]─[%{$fg[yellow]%}%~%{$fg[cyan]%}]
└─%{$fg[red]%}$%{$reset_color%} '

# Prompt à droite avec informations Git
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats '%{$fg[magenta]%}(%b)%{$reset_color%}'
RPROMPT='${vcs_info_msg_0_} %{$fg[cyan]%}[%D{%H:%M:%S}]%{$reset_color%}'

# Aliases ArchFusion
alias ll='ls -alF --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Aliases système
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'
alias c='clear'
alias h='history'
alias j='jobs -l'
alias path='echo -e ${PATH//:/\\n}'
alias now='date +"%T"'
alias nowtime=now
alias nowdate='date +"%d-%m-%Y"'

# Aliases ArchFusion spécifiques
alias archfusion-update='sudo pacman -Syu && yay -Syu'
alias archfusion-clean='sudo pacman -Rns $(pacman -Qtdq) 2>/dev/null || echo "Rien à nettoyer"'
alias archfusion-info='neofetch'
alias archfusion-logs='journalctl -f'
alias archfusion-services='systemctl --type=service --state=running'

# Aliases développement
alias g='git'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'
alias gs='git status'
alias gd='git diff'

# Aliases Docker
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps'
alias di='docker images'

# Fonctions utiles
mkcd() {
    mkdir -p "$1" && cd "$1"
}

extract() {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xjf $1     ;;
            *.tar.gz)    tar xzf $1     ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar e $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xf $1      ;;
            *.tbz2)      tar xjf $1     ;;
            *.tgz)       tar xzf $1     ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *)     echo "'$1' ne peut pas être extrait via extract()" ;;
        esac
    else
        echo "'$1' n'est pas un fichier valide!"
    fi
}

# Recherche rapide
ff() {
    find . -type f -name "*$1*"
}

fd() {
    find . -type d -name "*$1*"
}

# Variables d'environnement
export EDITOR='nano'
export VISUAL='nano'
export BROWSER='firefox'
export TERMINAL='konsole'

# PATH personnalisé
export PATH="$HOME/.local/bin:$PATH"
export PATH="/usr/local/bin:$PATH"

# Support pour les couleurs dans less
export LESS_TERMCAP_mb=$'\e[1;32m'
export LESS_TERMCAP_md=$'\e[1;32m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;31m'

# Message de bienvenue (uniquement pour les sessions interactives)
if [[ $- == *i* ]] && [[ -z "$TMUX" ]] && [[ -z "$ARCHFUSION_WELCOME_SHOWN" ]]; then
    echo "🚀 Bienvenue dans ArchFusion OS!"
    echo "💡 Tapez 'archfusion-help' pour l'aide"
    echo "🎯 Tapez 'archfusion-info' pour les infos système"
    export ARCHFUSION_WELCOME_SHOWN=1
fi

# Chargement des plugins Zsh si disponibles
if [ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

if [ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi