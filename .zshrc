# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Set up the prompt

autoload -Uz promptinit
promptinit
prompt adam1

setopt histignorealldups sharehistory

# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e

# Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history

# Use modern completion system
autoload -Uz compinit
compinit

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias vim=nvim
alias vi=vim

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# 定义文件名常量
CONVERSATION_FILE=/tmp/conversations/$$.jsonl
RESPONSE_FILE="/tmp/response.md"

# 封装 jq 命令的函数
append_to_conversation() {
    jq -n --arg role "$1" --arg content "$2" '{$role, $content}' >> "$CONVERSATION_FILE"
}

mkdir -p /tmp/conversations
append_to_conversation system "$(< system.txt)"

# 定义 command_not_found_handler 函数
command_not_found_handler() {
    # 追加用户消息到对话记录文件
    append_to_conversation user "$*"
    # 发送请求并处理响应
    curl --no-buffer -s https://open.bigmodel.cn/api/paas/v4/chat/completions \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $ZHIPU_API_KEY" \
        -d "$(jq -s '{model: "glm-4-flash", messages: ., stream: true}' < "$CONVERSATION_FILE")" |
        sed -u 's/^data: //g' | stdbuf -oL grep -v '\[DONE\]' |
        jq -rj --unbuffered '.choices[0].delta.content // empty' | tee "$RESPONSE_FILE"
    # 追加助手消息到对话记录文件
    append_to_conversation assistant "$(< $RESPONSE_FILE)"
}
