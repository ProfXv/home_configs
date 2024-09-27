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
source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias vim=nvim
alias vi=vim

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

source <(fzf --zsh)
export FZF_COMPLETION_TRIGGER='~~'

# 定义文件名常量
CONVERSATION_FILE=/tmp/conversations/$$.jsonl
RESPONSE_FILE="/tmp/response.md"

# 封装 jq 命令的函数
append_to_conversation() {
    jq -n --arg role "$1" --arg content "$2" '{$role, $content}' >> "$CONVERSATION_FILE"
}

get_response() {
    # Send request and process response
    curl --no-buffer -s https://open.bigmodel.cn/api/paas/v4/chat/completions \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $ZHIPU_API_KEY" \
        -d "$(jq -s '{
            model: "glm-4-flash",
            messages: .,
            tools: [{
                type: "function",
                function: {
                    name: "execute_terminal_command",
                    description: "Execute terminal command",
                    parameters: {
                        type: "object",
                        properties: {
                            command: {
                                type: "string",
                                description: "The terminal command to be executed."
                            }
                        },
                        required: ["command"]
                    }
                }
            }],
            tool_choice: "auto",
            stream: true
        }' < "$CONVERSATION_FILE")" | tee -a /tmp/conversation_log |
        sed -u 's/^data: //g' | while read -r line; do
    if [[ -z "$line" ]]; then
        continue
    elif [[ "$line" == "[DONE]" ]]; then
        echo "\033[32m[DONE]\033[0m" >&2
    elif echo -E "$line" | jq -rje '.choices[0].delta.content // empty'; then
        echo -E "$line" | jq -rje '.choices[0].delta.content // empty' >> $RESPONSE_FILE
    else
        prompt_tokens=$(echo -E "$line" | jq -r '.usage.prompt_tokens // empty')
        completion_tokens=$(echo -E "$line" | jq -r '.usage.completion_tokens // empty')
        total_tokens=$(echo -E "$line" | jq -r '.usage.total_tokens // empty')
        finish_reason=$(echo -E "$line" | jq -r '.choices[0].finish_reason // empty')

        if [ -n "$total_tokens" ]; then
            echo "$prompt_tokens + $completion_tokens = $total_tokens" >&2
        fi

        if [ -n "$finish_reason" ]; then
            echo "完成原因: $finish_reason" >&2
            case "$finish_reason" in
                "tool_calls")
                    COMMAND=$(echo -E "$line" | jq -r '.choices[0].delta.tool_calls[0].function.arguments | fromjson | .command')
                    echo "\033[31mExecuting: $COMMAND\033[0m" >&2
                    ;;
                *)
                    echo "$finish_reason" >&2
                    ;;
            esac
        fi
    fi
done
}

execute_conversation() {
    append_to_conversation "$1" "$2"
    get_response
    append_to_conversation assistant "$(< $RESPONSE_FILE)"
    # Execute the command if it's a terminal command
    if [[ -n $COMMAND ]]; then
        kitten @ send-text $COMMAND\\n
        unset COMMAND
        # execute_conversation tool "$(< $RESPONSE_FILE)"
    fi
}

mkdir -p /tmp/conversations
append_to_conversation system "$(< system.txt)"

natural_language_widget() {
    if [[ -z $BUFFER ]]; then
        zle -M "Hello boy!" # could be intelligent reminders later
    elif ! type ${BUFFER%% *} &>/dev/null; then
        echo
        execute_conversation user "$BUFFER"
        echo
        BUFFER=""
        zle accept-line
    else
        zle accept-line
        append_to_conversation tool "`kitty @ get-text --extent last_cmd_output`"
    fi
}

zle -N natural_language_widget
bindkey '^M' natural_language_widget
# 定义 command_not_found_handler 函数
# command_not_found_handler() {execute_conversation user "$*"}
