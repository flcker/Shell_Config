################################################################################
# function
# 定义一些常用的函数

# setproxy: 设置系统代理
function setproxy() {
  export http_proxy="http://127.0.0.1:7890"
  export https_proxy="http://127.0.0.1:7890"
  export all_proxy="socks5://127.0.0.1:7890"
}

# unsetproxy: 取消系统代理
function unsetproxy() {
  unset http_proxy
  unset https_proxy
  unset all_proxy
}
