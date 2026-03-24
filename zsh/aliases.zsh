################################################################################
# alias
# 定义一些常用的命令别名
alias yz='yazi'
alias ls='ls --color=auto'
alias ll='ls -alF'
alias la='ls -A'

alias cls='clear' # 清屏
alias reload='source ~/.zshrc' # 重新加载 zsh 配置

# git
alias gp="git push"                # Git 快捷操作
alias gs="git status"              # 查看 Git 状态
alias ga="git add"                 # 添加文件到暂存区
alias gc="git commit"              # 提交更改
alias gl="git log --oneline --graph --decorate"  # 美化的 Git

alias ..="cd .."                   # 返回上一级目录
alias ~="cd ~"                     # 返回家目录
alias ip="curl ifconfig.me"        # 查看公网 IP
alias ports="lsof -iTCP -sTCP:LISTEN -P"  # 查看监听端口
