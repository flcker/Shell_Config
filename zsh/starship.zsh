################################################################################
# starship
# 随机从submodule/starship/ 目录下的starship配置文件中选取一个，设置为当前的starship配置
STARSHIP_DIR="$HOME/.config/zsh/submodule/starship"

function __starship_random_config() {
  local files=("$STARSHIP_DIR"/starship*.toml(N-.))
  if (( ${#files} == 0 )); then
    echo ""
    return 0
  fi
  echo "${files[$((RANDOM % ${#files} + 1))]}"
}

export STARSHIP_CONFIG="$(__starship_random_config)"
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# 增加ssc 命令，切换starship配置文件
# 使用方法：ssc
# 参数：
# <custom|c, starship_custom.toml> 切换到自定义配置文件
# <powerline|p, starship_powerline.toml> 切换到powerline配置文件
# <plaintextsymbols|t, starship_plaintextsymbols.toml> 切换到plaintextsymbols配置文件
# <random|r|""> 切换到随机配置文件，如果不带参数，则默认切换到随机配置文件
function ssc() {
  case "$1" in
    custom|c)
      export STARSHIP_CONFIG="$STARSHIP_DIR/starship_custom.toml"
      ;;
    powerline|p)
      export STARSHIP_CONFIG="$STARSHIP_DIR/starship_powerline.toml"
      ;;
    plaintextsymbols|t)
      export STARSHIP_CONFIG="$STARSHIP_DIR/starship_plaintextsymbols.toml"
      ;;
    random|r|"")
      export STARSHIP_CONFIG="$(__starship_random_config)"
      ;;
    *)
      echo "Usage: ssc <custom|c|powerline|p|plaintextsymbols|t|random|r>"
      return 1
      ;;
  esac
  echo "Switched to starship config: $STARSHIP_CONFIG"
}
