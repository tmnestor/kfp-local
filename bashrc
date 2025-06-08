#!/bin/bash
# filepath: ~/.bashrc
# =============================================================================
# JupyterHub Linux Compatible Bash Configuration
# =============================================================================
# This bashrc has been modified for Linux/JupyterHub environments:
# - Conda paths adapted for common Linux installations
# - Modern CLI tools include fallbacks for restricted environments
# - Editor defaults to vim for SSH/JupyterHub sessions
# =============================================================================

# =============================================================================
# Bash Performance Optimizations
# =============================================================================

# Fast shell startup: enable programmable completion
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# =============================================================================
# Conda Environment Setup (Early for Fast Access)
# =============================================================================

# >>> conda initialize >>>
# Check for conda in common Linux/JupyterHub locations
CONDA_PATHS=(
    "/opt/conda"
    "/opt/miniconda3"
    "/usr/local/miniconda3"
    "$HOME/miniconda3"
    "$HOME/anaconda3"
    "$HOME/conda"
)

for conda_path in "${CONDA_PATHS[@]}"; do
    if [ -f "$conda_path/bin/conda" ]; then
        __conda_setup="$('$conda_path/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
        if [ $? -eq 0 ]; then
            eval "$__conda_setup"
        else
            if [ -f "$conda_path/etc/profile.d/conda.sh" ]; then
                . "$conda_path/etc/profile.d/conda.sh"
            else
                export PATH="$conda_path/bin:$PATH"
            fi
        fi
        break
    fi
done
unset __conda_setup
# <<< conda initialize <<<

# =============================================================================
# PATH Configuration
# =============================================================================

# User paths
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# =============================================================================
# Environment Variables
# =============================================================================

# Data Science & ML Directories
# Note: Adjust these paths based on your JupyterHub environment
export DATADIR="$HOME/data"
export MODELDIR="$HOME/models"
export CONDA_ENVS="$HOME/conda_envs"
export LLM_MODELS_PATH="$HOME/PretrainedLLM"
export HF_HOME="$HOME/PretrainedLLM"

# System Configuration
export LANG="en_US.UTF-8"
export ARCHFLAGS="$(uname -m)"

# Python/Build Configuration
export GRPC_PYTHON_BUILD_SYSTEM_OPENSSL=1
export GRPC_PYTHON_BUILD_SYSTEM_ZLIB=1
export FTC_OUTPUT_PATH="$HOME/bert_outputs"

# =============================================================================
# History Configuration
# =============================================================================

export HISTTIMEFORMAT="%Y-%m-%d %T "
export HISTFILE="$HOME/.bash_history"
export HISTSIZE=1000000
export HISTFILESIZE=1000000

# History options
shopt -s histappend
export HISTCONTROL=ignoreboth:erasedups
export PROMPT_COMMAND="history -a"

# =============================================================================
# Shell Options
# =============================================================================

# Enable extended globbing
shopt -s extglob
# Enable case-insensitive globbing
shopt -s nocaseglob
# Enable cdspell for minor directory spelling errors
shopt -s cdspell
# Enable dirspell for directory name completion
shopt -s dirspell

# =============================================================================
# Editor Configuration
# =============================================================================

# Default to vim for JupyterHub environments (VS Code may not be available)
if [[ -n $SSH_CONNECTION ]] || [[ -n $JUPYTERHUB_USER ]]; then
    export EDITOR='vim'
elif command -v code >/dev/null 2>&1; then
    export EDITOR='code -w'
else
    export EDITOR='vim'
fi

# =============================================================================
# Python aliases
# =============================================================================
alias python='python3'
alias pip='pip3'

# =============================================================================
# Safety Aliases
# =============================================================================

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# =============================================================================
# Navigation & Listing Aliases
# =============================================================================

alias ..='cd ..'
alias ...='cd ../..'

# =============================================================================
# Utility Aliases
# =============================================================================

alias tree='tree -C'                                                          # Display directory tree with colors
alias du='du -h'                                                              # Show disk usage in human-readable format
alias df='df -h'                                                              # Show filesystem disk space in human-readable format
alias mkdir='mkdir -pv'                                                       # Create directories recursively with verbose output
alias wget='wget -c'                                                          # Resume incomplete downloads automatically
alias histg='history | grep'                                                  # Search command history: histg searchterm
alias psg='ps aux | grep -v grep | grep -i -e VSZ -e'                         # Search running processes: psg processname
alias rmpycache='find . -type d -name "__pycache__" -exec rm -r {} +'         # Remove all Python cache directories recursively

# Modern CLI tool aliases (with fallbacks to traditional tools)
# Note: exa, bat, fd, rg, htop, nvim may not be available in JupyterHub - fallbacks provided
alias ls='exa --color=auto --group-directories-first 2>/dev/null || ls --color=auto'  # Basic listing with dirs first
alias ll='exa -la --icons --git 2>/dev/null || ls -alF'                               # Long format with icons & git status
alias la='exa -a 2>/dev/null || ls -A'                                                # Show all files (including hidden)
alias l='exa -1 2>/dev/null || ls -CF'                                                # Single column listing
alias cat='bat --style=plain 2>/dev/null || cat'                                      # Syntax highlighting for file contents
alias find='fd 2>/dev/null || find'                                                   # Faster file search
alias grep='rg 2>/dev/null || grep --color=auto'                                      # Faster text search with ripgrep

alias top='htop 2>/dev/null || top'
alias vim='nvim 2>/dev/null || vim'
alias cls='clear'
alias reload='source ~/.bashrc'
alias bashconfig='code ~/.bashrc'

# Conda/Mamba convenience aliases
alias mamba-create='mamba env create -f environment.yml'
alias mamba-update='mamba env update -f environment.yml --prune'
alias mamba-export='mamba env export > environment.yml'
# Flexible conda activation - works with various conda installations
alias conda-activate='
    for conda_path in /opt/conda /opt/miniconda3 /usr/local/miniconda3 "$HOME/miniconda3" "$HOME/anaconda3" "$HOME/conda"; do
        if [ -f "$conda_path/etc/profile.d/conda.sh" ]; then
            source "$conda_path/etc/profile.d/conda.sh" && conda activate
            break
        fi
    done'
alias mamba-install='mamba install -c conda-forge'

# Git aliases for common operations
alias gs='git status'
alias gd='git diff'
alias gl='git log --oneline --graph --decorate'
alias gp='git push'
alias ga='git add'
alias gco='git checkout'

# Shared directory aliases
alias share='sharedir'                                                         # Quick shared permissions
alias shared='sharedir'                                                        # Alternative name
alias mkshare='mkshared'                                                       # Create shared directory
alias chkshare='checkshare'                                                    # Check if in shared location
alias lshare='ls -la | grep "^d.*rw.rw"'                                       # List directories with group write permissions

# =============================================================================
# Custom Functions
# =============================================================================

# System power management (Linux equivalents)
nosleep() {
    sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
}

yessleep() {
    sudo systemctl unmask sleep.target suspend.target hibernate.target hybrid-sleep.target
}

# Git quick commit
gc() {
    git commit --no-verify -m "$*"
}

# Enhanced history search with fzf
fh() {
    local selected
    selected=$(history | fzf --tac --no-sort --height=40% --reverse | sed 's/^[ ]*[0-9]*[ ]*[0-9-]*[ ]*[0-9:]*[ ]*//')
    if [[ -n "$selected" ]]; then
        eval "$selected"
    fi
}

# Quick directory navigation with error handling and shared directory detection
cdl() { 
    if [[ -d "$1" ]]; then
        cd "$1" && ls -la
        # Check if we're in a shared location and suggest permissions if needed
        if [[ "$PWD" == */efs/shared* ]] || [[ "$PWD" == */shared* ]] || [[ "$PWD" == */data* ]]; then
            echo ""
            echo "🔗 In shared location - run 'sharedir' to apply team permissions if needed"
        fi
    else
        echo "Directory '$1' does not exist"
        return 1
    fi
}

# Extract function for various archive types
extract() {
    if [ -f "$1" ] ; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar e "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)     echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Create and enter directory with automatic shared permissions
mkcd() {
    mkdir -p "$1" && cd "$1"
    # Auto-apply shared permissions if in shared locations
    if [[ "$PWD" == */efs/shared* ]] || [[ "$PWD" == */shared* ]] || [[ "$PWD" == */data* ]]; then
        echo "Applying shared permissions (2770) to $1..."
        chmod -R 2770 "$1" 2>/dev/null || echo "Note: Could not set permissions (may need sudo)"
    fi
}

# Shared directory management functions
sharedir() {
    # Apply shared permissions to current directory or specified directory
    local target="${1:-.}"
    echo "Setting shared permissions (2770) on: $target"
    chmod -R 2770 "$target" 2>/dev/null || {
        echo "Permission denied. Trying with sudo..."
        sudo chmod -R 2770 "$target"
    }
    echo "Shared permissions applied successfully!"
}

# Create shared directory with proper permissions
mkshared() {
    if [[ -z "$1" ]]; then
        echo "Usage: mkshared <directory_name>"
        return 1
    fi
    mkdir -p "$1"
    chmod -R 2770 "$1" 2>/dev/null || {
        echo "Setting permissions with sudo..."
        sudo chmod -R 2770 "$1"
    }
    echo "Shared directory '$1' created with permissions 2770"
}

# Check if current directory needs shared permissions
checkshare() {
    local current_dir="${1:-$PWD}"
    if [[ "$current_dir" == */efs/shared* ]] || [[ "$current_dir" == */shared* ]] || [[ "$current_dir" == */data* ]]; then
        echo "📁 In shared location: $current_dir"
        echo "Current permissions:"
        ls -la . | head -5
        echo ""
        echo "💡 Tip: Run 'sharedir' to apply shared permissions (2770)"
    else
        echo "📁 Not in shared location: $current_dir"
    fi
}

# Find and kill process
fkill() {
    local pid
    pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
    if [ "x$pid" != "x" ]; then
        echo $pid | xargs kill -${1:-9}
    fi
}

# Quick conda environment activation
ca() {
    if [[ -n "$1" ]]; then
        conda activate "$1"
    else
        conda info --envs | fzf | awk '{print $1}' | xargs conda activate
    fi
}

# =============================================================================
# Third-party Tool Integration
# =============================================================================

# FZF integration with error handling
if command -v fzf >/dev/null 2>&1; then
    if [ -f ~/.fzf.bash ]; then
        source ~/.fzf.bash
    fi
fi

# Bind custom history search to Ctrl-R (if fzf available)
if command -v fzf >/dev/null 2>&1; then
    bind -x '"\C-r": fh'
fi

# =============================================================================
# Custom Prompt Configuration
# =============================================================================

# Disable conda prompt modification
conda config --set changeps1 false 2>/dev/null

# Function to get conda environment info
get_conda_env() {
    if [[ -n $CONDA_PREFIX ]]; then
        local env_name=$(basename "$CONDA_PREFIX")
        if [[ "$env_name" == "miniconda3" ]] || [[ "$env_name" == "base" ]]; then
            echo "(base) "
        else
            echo "($env_name) "
        fi
    fi
}

# Function to get git branch
parse_git_branch() {
    git branch 2>/dev/null | sed -n -e 's/^\* \(.*\)/[\1]/p'
}

# Define colors for bash
COLOR_CON='\[\033[38;5;141m\]'
COLOR_DEF='\[\033[0m\]'
COLOR_USR='\[\033[38;5;247m\]'
COLOR_DIR='\[\033[38;5;33m\]'
COLOR_GIT='\[\033[38;5;215m\]'

# Set the prompt
PS1="${COLOR_CON}\$(get_conda_env)${COLOR_USR}\u ${COLOR_DIR}\W ${COLOR_GIT}\$(parse_git_branch)${COLOR_DEF}\$ "

# =============================================================================
# Linux-specific adjustments
# =============================================================================

# Enable color support for ls and grep
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# =============================================================================
# JupyterHub Linux Environment Compatibility
# =============================================================================
# This bashrc is configured for JupyterHub Linux environments
# Some tools may not be available - aliases include fallbacks to standard tools

# Make less more friendly for non-text input files
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"
