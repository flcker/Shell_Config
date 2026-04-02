################################################################################
# nodejs 配置
# 设置 npm 镜像源
official_npm_mirror="https://registry.npmjs.org/"
taobao_npm_mirror="https://registry.npmmirror.com/"
# 默认使用淘宝的镜像源
# 切换 npm 镜像源的函数
function npmswitch() {
  case "$1" in
    official|o)
      npm config set registry $official_npm_mirror
      ;;
    taobao|t)
      npm config set registry $taobao_npm_mirror
      ;;
    list)
      echo "Current npm registry: $NPM_CONFIG_REGISTRY"
      echo "Available options:"
      echo "  official (o) - Official npm registry"
      echo "  taobao (t) - Taobao npm registry"
      return 0
      ;;
    *)
      echo "Usage: npmswitch <official|o|taobao|t>"
      return 1
      ;;
  esac
  echo "Switched npm registry to: $NPM_CONFIG_REGISTRY"
}

# main 函数
function main() {
  npmswitch taobao
  exit $?
}

# 入口函数
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main
fi
