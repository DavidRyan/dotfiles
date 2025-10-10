# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Timothy's zsh configuration file.
#
# Checkout into ~/.zsh
#   ln -sv .zsh/.zshrc ~/.zshrc
#
#   brew install zsh-completions zsh-syntax-highlighting
#   brew cask install sublime-text 
#   chsh -s /bin/zsh
#
#   sudo apt-get install zsh zsh-syntax-highlighting sublime-text-installer
#   chsh -s /usr/bin/zsh
#
#
#enable fzf
#ctrl + t
source <(fzf --zsh)

# Enable local overrides for zsh configuration
if [[ -s ~/.zsh/.zshrc.local ]]; then
  source ~/.zsh/.zshrc.local
fi
# Add all files in ~/.zsh as autoloaded functions
#fpath=(~/.zsh $fpath)
#autoload $(ls ~/.zsh)

# Different useful things making Zsh more powerful
autoload -U zmv
setopt extended_glob

# Enable colored output for ls
export CLICOLOR=YES # MacOS
if which dircolors &>/dev/null; then
  alias ls="ls --color=auto"
fi
# Use nano and subl if graphics is available
export EDITOR="nano"
if [[ -n "$DISPLAY" || "$TERM_PROGRAM" = "Apple_Terminal" ]]; then 
  export VISUAL="subl -w"
fi

# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
bindkey -e
# End of lines configured by zsh-newuser-install
# Share history between tmux windows
setopt SHARE_HISTORY
setopt hist_ignore_space
setopt histignoredups

# The following lines were added by compinstall

zstyle ':completion:*' completer _complete _ignored
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt '%SAt %p: Hit TAB for more, or the character to insert%s'
zstyle ':completion:*' matcher-list 'r:|[._-]=* r:|=*'
zstyle ':completion:*' menu select=1
zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'
zstyle :compinstall filename '~/.zshrc'
fpath=(/usr/local/share/zsh-completions $fpath)

autoload -Uz compinit
compinit -u
# End of lines added by compinstall

# Support TAB/TAB/TAB for repeated autocompletion
zmodload zsh/complist
bindkey -M menuselect '^I' accept-and-infer-next-history

# Workaround for zsh 5.2 release 
autoload +X VCS_INFO_nvcsformats
functions[VCS_INFO_nvcsformats]=${functions[VCS_INFO_nvcsformats]/local -a msgs/}
# # Lines for vcs_info prompt configuration
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' stagedstr '%{%F{green}%B%}●%{%b%f%}'
zstyle ':vcs_info:*' unstagedstr '%{%F{red}%B%}●%{%b%f%}'
zstyle ':vcs_info:*' formats '%{%F{cyan}%}%45<…<%R%<</%{%f%}%{%F{green}%}(%25>…>%b%<<)%{%f%}%{%F{cyan}%}%S%{%f%}%c%u'
zstyle ':vcs_info:*' actionformats '%{%F{cyan}%}%45<…<%R%<</%{%f%}%{%F{red}%}(%a|%m)%{%f%}%{%F{cyan}%}%S%{%f%}%c%u'
zstyle ':vcs_info:*' nvcsformats '%{%F{cyan}%}%~%{%f%}'
zstyle ':vcs_info:git:*' patch-format '%10>…>%p%<< (%n applied)'
zstyle ':vcs_info:*+set-message:*' hooks home-path
function +vi-home-path() {
  # Replace $HOME with ~
  hook_com[base]="$(echo ${hook_com[base]} | sed "s/${HOME:gs/\//\\\//}/~/" )"
}
zstyle ':vcs_info:git+post-backend:*' hooks git-remote-staged
function +vi-git-remote-staged() {
  # Show "unstaged" when changes are not staged or not committed
  # Show "staged" when last committed is not pushed
  #
  # See original VCS_INFO_get_data_git for implementation details

  # Set "unstaged" when git reports either staged or unstaged changes
  if (( gitstaged || gitunstaged )) ; then
    gitunstaged=1
  fi

  # Set "staged" when current HEAD is not present in the remote branch
  if (( querystaged )) && \
     [[ "$(${vcs_comm[cmd]} rev-parse --is-inside-work-tree 2> /dev/null)" == 'true' ]] ; then
      # Default: off - these are potentially expensive on big repositories
      if ${vcs_comm[cmd]} rev-parse --quiet --verify HEAD &> /dev/null ; then
          gitstaged=1
          if ${vcs_comm[cmd]} status --branch --short | head -n1 | grep -v ahead > /dev/null ; then
            gitstaged=
          fi
      fi
  fi

  hook_com[staged]=$gitstaged
  hook_com[unstaged]=$gitunstaged
}
autoload -Uz vcs_info
function precmd() { vcs_info }
setopt prompt_subst
#PROMPT='%(?..%{%F{red}%}%?%{%f%} )%{%F{green}%}%n%{%f%}@%{%F{red}%}%m%{%f%}:${vcs_info_msg_0_}%{%B%}%(!.#.>)%{%b%E%} '
# End of lines for vcs_info prompt configuration


# Support keyboard navigation in the command prompt
bindkey "^[[1;3H" backward-word # Fn-Option-Left, Option-Home
bindkey "^[[1;3F" forward-word  # Fn-Option-Right, Option-End
bindkey "${terminfo[khome]}" beginning-of-line # Fn-Left, Home
bindkey "${terminfo[kend]}" end-of-line # Fn-Right, End
# Ctrl-X-e and Ctrl-Space to edit in the editor
autoload -U edit-command-line
zle -N edit-command-line
bindkey '^Xe' edit-command-line
bindkey '^ ' edit-command-line


# Enable inline syntax highlighting
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[path]='fg=cyan,bold'
ZSH_HIGHLIGHT_STYLES[path_prefix]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[redirection]='fg=cyan,bold'
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]='fg=magenta,bold'
if [[ -s /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
if [[ -s /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
source ~/gitstatus/gitstatus.prompt.zsh
source ~/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

export TERM="xterm-256color"


export OPENAI_API_KEY='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'
export DISCORD_TOKEN='MTM1NDkxMjE3MzU0NTIzMDM3Nw.G30Tiu.M3Q9NDuCpC0R-325HSEQ6xBV47NtsXZx62EP_s'

export PATH="$HOME/bin:$PATH"
export PATH="/opt/homebrew/bin:$PATH"
export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"

# Alais
alias vim='nvim'
alias nivm='nvim'
