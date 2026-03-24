################################################################################
# brew
# 设置 Homebrew 的镜像源，提升安装和更新的速度
# 通过环境变量方式引用，方便后续通过函数切换镜像源
# tsinghua https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles
# ustc https://mirrors.ustc.edu.cn/homebrew-bottles
# official https://homebrew.bintray.com/bottles
tinghua_mirror="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"
ustc_mirror="https://mirrors.ustc.edu.cn/homebrew-bottles"
official_mirror="https://homebrew.bintray.com/bottles"

# 默认使用清华大学的镜像源
export HOMEBREW_BOTTLE_DOMAIN=$tinghua_mirror
# 切换 Homebrew 镜像源的函数
function brewswitch() {
  case "$1" in
    tsinghua|t)
      export HOMEBREW_BOTTLE_DOMAIN=$tinghua_mirror
      ;;
    ustc|u)
      export HOMEBREW_BOTTLE_DOMAIN=$ustc_mirror
      ;;
    official|o)
      export HOMEBREW_BOTTLE_DOMAIN=$official_mirror
      ;;
    *)
      echo "Usage: brewswitch <tsinghua|t|ustc|u|official|o>"
      return 1
      ;;
  esac
  echo "Switched Homebrew bottle domain to: $HOMEBREW_BOTTLE_DOMAIN"
}
