################################################################################
# fzf
# Set up fzf key bindings and fuzzy completion

############################################
# 1. 开启 Zsh 原生补全系统 (必须在 fzf 之前)
autoload -Uz compinit
compinit
# 让原生的 Tab 补全菜单支持方向键选择
zstyle ':completion:*' menu select

############################################
# 2. 挂载 Homebrew 环境变量
# 兼容 M1/M2/M3 和 Intel 芯片的 Homebrew 路径
if [[ -d "/opt/homebrew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -d "/usr/local" ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

############################################
# 3. fzf 基础 UI 定制 (可选，提升颜值)
# 设置为反向布局（搜索框在下方居中），带边框
export FZF_DEFAULT_OPTS="--height 50% --layout=reverse --border"

############################################
# 4. 挂载 fzf 快捷键与命令补全
# 如果 ～/.fzf.zsh 存在 则使用已有的配置；否则，使用 fzf 的默认动态配置
if [[ -f ~/.fzf.zsh ]]; then
    source ~/.fzf.zsh
else
    source <(fzf --zsh)
fi
