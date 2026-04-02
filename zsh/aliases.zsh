################################################################################
# alias
# 定义一些常用的命令别名
alias cls='clear' # 清屏
alias rezsh='source ~/.zshrc' # 重新加载 zsh 配置

alias ..="cd .."                   # 返回上一级目录
alias ~="cd ~"                     # 返回家目录
alias ip="curl ifconfig.me"        # 查看公网 IP
alias ports="lsof -iTCP -sTCP:LISTEN -P"  # 查看监听端口

# ghostty
if command -v ghostty >/dev/null 2>&1; then
    alias gty='ghostty'              # 使用 ghostty 替代 gty
fi

# git
if command -v git >/dev/null 2>&1; then
    alias gp="git push"                # Git 快捷操作
    alias gs="git status"              # 查看 Git 状态
    alias ga="git add"                 # 添加文件到暂存区
    alias gc="git commit"              # 提交更改
    alias gl="git log --oneline --graph --decorate"  # 美化的 Git 日志显示
fi

# 判断 lsd 是否存在
if command -v lsd >/dev/null 2>&1; then
    alias ls='lsd --color=auto'         # 使用 lsd 替代 ls
    alias ll='lsd -alF'                 # 使用 lsd 替代 ll
    alias la='lsd -A'                   # 使用 lsd 替代 la
else
    alias ls='ls --color=auto'
    alias ll='ls -alF'
    alias la='ls -A'
fi

# yazi
if command -v yazi >/dev/null 2>&1; then
    alias yz='yazi'                     # 使用 yazi 替代 yz
fi

# zoxide
if command -v zoxide >/dev/null 2>&1; then
    alias z='zoxide'                   # 使用 zoxide 替代 z
    alias zls='zoxide query -l'        # 列出 zoxide 数据库中的目录
fi

# bat
if command -v bat >/dev/null 2>&1; then
    alias cat='bat --paging=never'     # 使用 bat 替代 cat
fi
