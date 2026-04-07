################################################################################
# plugins
plugins=(
  # fzf
  # git
  zsh-autosuggestions
  zsh-syntax-highlighting
)

# zsh-autosuggestions 和 zsh-syntax-highlighting 通过 brew 安装时，插件目录在 Homebrew 前缀下
# 如：/opt/homebrew/share 或 /usr/local/share，而不是 $ZSH/plugins。
# 如果你是通过 brew 安装这些插件，请根据实际路径修改下面两行 source 命令。


function load_plugin {
    local plugin_name="$1"

    # 如果插件已经在 $ZSH/custom/plugins 或 $ZSH/plugins 下，优先从这些目录加载
    if [ -n "$ZSH" ]; then
      if [ -f "$ZSH/custom/plugins/$plugin_name/$plugin_name.zsh" ]; then
        source "$ZSH/custom/plugins/$plugin_name/$plugin_name.zsh"
        return
      elif [ -f "$ZSH/plugins/$plugin_name/$plugin_name.zsh" ]; then
        source "$ZSH/plugins/$plugin_name/$plugin_name.zsh"
        return
      fi
    fi

    # 尝试从 Homebrew 常见路径加载（Apple Silicon 与 Intel）
    local brew_prefixes=(
      "/opt/homebrew/share"   # Apple Silicon 默认前缀
      "/usr/local/share"      # Intel 默认前缀
    )

    local candidate
    for prefix in "${brew_prefixes[@]}"; do
      candidate="${prefix}/${plugin_name}/${plugin_name}.zsh"
      if [ -f "$candidate" ]; then
        source "$candidate"
        return
      fi
    done

    # 如果以上路径都不存在，则给出提示，方便用户排查
    echo "[zsh] 未找到插件: $plugin_name。请确认插件安装位置，并在 load_plugin 中补充相应路径。" >&2
}

for plugin in "${plugins[@]}"; do
  load_plugin "$plugin"
done
