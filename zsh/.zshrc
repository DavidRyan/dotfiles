export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
export COLORTERM=truecolor

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#555555'

#plugins=(git zsh-syntax-highlighting zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh

# Make sure syntax highlighting is sourced last for compatibility:
#source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
bindkey '^F' autosuggest-accept

pokeget random --hide-name --mega-x --mega-y -s

# opencode
export PATH=/home/david/.opencode/bin:$PATH

alias fastfetch='pokeget random --hide-name --mega-x --mega-y -s |
fastfetch --file-raw -'
