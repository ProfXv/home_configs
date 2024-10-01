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
RESPONSE_FILE=/tmp/response.md
RESPONSE_STATE=false

# 封装 jq 命令的函数
append_to_conversation() {
    jq -n --arg role "$1" --arg content "$2" '{$role, $content}' >> $CONVERSATION_FILE
}

mkdir -p /tmp/conversations
append_to_conversation system "$(< system.txt)"

execute_conversation() {
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
                    name: "terminal_command",
                    description: "Execute any linux zsh terminal command",
                    parameters: {
                        type: "object",
                        properties: {
                            command: {
                                type: "string",
                                description: "The whole terminal command to be executed."
                            }
                        },
                        required: ["command"]
                    }
                }
            }],
            tool_choice: "auto",
            stream: true
        }' < "$CONVERSATION_FILE")" | tee -a /tmp/conversation_log | sed -u 's/^data: //g' |
        while read -r line; do
            if [[ -z "$line" ]]; then
                continue
            elif [[ "$line" == "[DONE]" ]]; then
                echo "\033[32m[DONE]\033[0m" >&2
            else
                delta=$(echo -E $line | jq -r '.choices[0].delta')
                content=$(echo -E $delta | jq -re '.content // empty') &&
                echo -n $content | tee -a $RESPONSE_FILE ||
                FUNCTION=$(echo -E $delta | jq -r '.tool_calls[0].function')
                # for debugging use
                if [ -n "$FUNCTION" ]; then func_line="$line"; fi
                usage=$(echo -E $line | jq -r '.usage // empty')
                if [ -n "$usage" ]; then
                    echo \\n
                    in_tokens=$(echo $usage | jq -r '.prompt_tokens')
                    out_tokens=$(echo $usage | jq -r '.completion_tokens')
                    total_tokens=$(echo $usage | jq -r '.total_tokens')
                    finish_reason=$(echo $line | jq -r '.choices[0].finish_reason')
                    echo "\033[33mUsage: $in_tokens + $out_tokens = $total_tokens\033[0m" >&2
                    echo "\033[34mFinish reason: $finish_reason\033[0m" >&2
                fi
            fi
        done
    RESPONSE_STATE=false
    if [[ -n "$(< $RESPONSE_FILE)" ]]; then
        append_to_conversation assistant "$(< $RESPONSE_FILE)"
        rm $RESPONSE_FILE
    fi
}

handle_conversation() {
    zle -M ""
    echo
    execute_conversation
    echo
    if [[ -n $FUNCTION ]]; then
        name=$(echo -E $FUNCTION | jq -r '.name')
        call=$(echo -E $FUNCTION | jq -r '.arguments | fromjson')
        case $name in
            terminal_command)
                command=$(echo -E $call | jq -r '.command')
                echo "\033[31mExecuting:\n\033[0m" >&2
                BUFFER="$command"
                ;;
            file_operations)
                operation=$(echo -E $call | jq -r '.operation')
                file=$(echo -E $call | jq -r '.file')
                case $operation in
                    Read)
                        cmd="cat $file"
                        ;;
                    Write)
                        content=$(echo -E $call | jq -r '.content')
                        cmd="echo \"$content\" >$file"
                        ;;
                    *)
                        cmd="echo '无效的操作'"
                        echo -E $call
                        ;;
                esac
                echo "\033[31m$operation: $file\n\033[0m" >&2
                append_to_conversation tool "$(eval $cmd)"
                unset BUFFER
                ;;
        esac
        zle accept-line
        RESPONSE_STATE=true
        unset FUNCTION
        # could add a while loop later
        # execute_conversation
    else
        unset BUFFER
        zle accept-line
    fi
}

natural_language_widget() {
    if [[ -z $BUFFER ]]; then
        if $RESPONSE_STATE; then
            handle_conversation
        else
            zle -M "No available query since last reply." # could be intelligent reminders later
        fi
    elif ! type ${BUFFER%% *} &>/dev/null; then
        append_to_conversation user "$BUFFER"
        handle_conversation
    else
        zle accept-line
        RESPONSE_STATE=true
    fi
}

precmd() {
    if $RESPONSE_STATE; then
        append_to_conversation tool "$(jq -nc --arg in "`fc -ln -1`" --arg out "`kitty @ get-text --extent last_cmd_output`" '{$in, $out}')"
    fi
}

zle -N natural_language_widget
bindkey '^M' natural_language_widget
# 定义 command_not_found_handler 函数
# command_not_found_handler() {execute_conversation user "$*"}

check_conversation() {zle -M "`cat $CONVERSATION_FILE`"}
zle -N check_conversation
bindkey '^J' check_conversation
