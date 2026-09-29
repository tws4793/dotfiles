# Prompt: user (red if root)  cwd  branch:hash
#         > (red if the last command failed)
# ~/.config/bash/prompt.bash draws the same prompt in bash.

# Git
autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )

setopt prompt_subst
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' get-revision true
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:git:*' formats '%b:%8.8i'

prompt_detailed() {
    local items=(
        #'%*'
        '%F{%(!.red.green)}%n%f'
        '%F{8}%~%f'
        \$vcs_info_msg_0_
        '\n%F{%(?.green.red)}>%f'
    )
    echo "%B%F{8}$items %f%b"
}
PROMPT=$(prompt_detailed)
