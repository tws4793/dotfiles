# Same prompt as ~/.config/zsh/prompt.zsh:
#   user (red if root)  cwd  branch:hash
#   > (red if the last command failed)

__prompt_git() {
    local hash ref
    hash=$(git rev-parse --verify -q HEAD 2>/dev/null) || return 0
    ref=$(git symbolic-ref --short -q HEAD 2>/dev/null) || ref=${hash:0:7}
    printf '%s:%s' "$ref" "${hash:0:8}"
}

__prompt() {
    local status=$? user_color='\[\e[32m\]' status_color='\[\e[32m\]'
    local bold='\[\e[1m\]' grey='\[\e[90m\]' reset='\[\e[39m\]' off='\[\e[0m\]'
    [ "$EUID" -eq 0 ] && user_color='\[\e[31m\]'
    [ "$status" -ne 0 ] && status_color='\[\e[31m\]'
    # Referenced as a variable so a branch name can't inject prompt expansions
    __prompt_git_info=$(__prompt_git)
    PS1="${bold}${grey}${user_color}\u${reset} ${grey}\w${reset} \${__prompt_git_info} \n${status_color}>${reset} ${off}"
}

case ";${PROMPT_COMMAND-};" in
    *";__prompt;"*) ;;
    *) PROMPT_COMMAND="__prompt${PROMPT_COMMAND:+;$PROMPT_COMMAND}" ;;
esac
