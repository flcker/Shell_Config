#!/bin/bash

# init bash
# 用来初始化安装一些工具，设置环境变量等

# 处理 Ctrl+C 中断信号，优雅地退出脚本
function handle_interrupt() {
  echo "Interrupted."
  exit 130
}

trap handle_interrupt INT


# 定义 brew install list
brew_install_list=(
  "git" # Git 是一个分布式版本控制系统，用于跟踪文件的更改和协作开发
  "lazygit" # Lazygit 是一个基于终端的 Git 用户界面，提供更直观的 Git 操作体验
  "starship" # 一个跨平台的 shell 提示符，支持多种主题和插件
  "sheldon" # sheldon 是一个快速的 zsh 插件管理器，支持 GitHub 插件和 inline 插件
  "thefuck" # thefuck 是一个命令行工具，用于自动纠正上一条命令的错误
  "zoxide" # Zoxide 是一个快速的目录切换工具，类似于 autojump 和 z.lua
  "lsd" # lsd 是一个现代化的 ls 命令替代品，提供更丰富的输出和更好的用户体验
  "bat" # bat 是一个现代化的 cat 命令替代品，提供语法高亮和分页功能
  "fd" # fd 是一个现代化的 find 命令替代品，提供更快的搜索速度和更友好的界面
  "fzf" # fzf 是一个通用的命令行模糊查找工具，可以用于文件搜索、历史命令搜索等
  "ripgrep" # ripgrep 是一个快速的文本搜索工具，类似于 grep，但更快且支持更多功能
  "btop" # btop 是一个资源监视工具，类似于 htop，但提供更丰富的功能和更好的界面
  "htop" # htop 是一个交互式的进程查看器和系统监视器，提供实时的系统资源使用情况
  "glow" # glow 是一个命令行 Markdown 渲染器，可以在终端中美观地显示 Markdown 文件
  "neovim" # Neovim 是一个现代化的文本编辑器，基于 Vim，提供更好的性能和更多的功能
  "tlrc" # tlrc 是 Official tldr client written in Rust. tldr的rust实现。
)

# 提示用户选择要安装的工具，显示安装列表
# 安装 并统计安装结果，输出安装成功和失败的工具列表
function is_installed() {
  local tool="$1"

  if brew list --versions "${tool}" >/dev/null 2>&1; then
    return 0
  fi

  if brew list --cask "${tool}" >/dev/null 2>&1; then
    return 0
  fi

  if command -v "${tool}" >/dev/null 2>&1; then
    return 0
  fi

  return 1
}

function get_brew_version() {
  local tool="$1"
  local version=""

  if command -v python3 >/dev/null 2>&1; then
    version="$(brew info --json=v2 "${tool}" 2>/dev/null | python3 - <<'PY'
import json
import sys

try:
    data = json.load(sys.stdin)
except Exception:
    print("")
    raise SystemExit(0)

def extract(items):
    for item in items or []:
        installed = item.get("installed") or []
        if installed:
            ver = installed[0].get("version")
            if ver:
                return ver
    return ""

print(extract(data.get("formulae")) or extract(data.get("casks")) or "")
PY
)"
  fi

  if [[ -z "${version}" ]]; then
    version="$(brew list --versions "${tool}" 2>/dev/null | awk '{print $2; exit}')"
  fi

  if [[ -z "${version}" ]]; then
    version="unknown"
  fi

  echo "${version}"
}

function install_tools() {
  if [[ $# -eq 0 ]]; then
    echo "install_tools requires an install queue (array name or package list)."
    return 1
  fi

  local -a install_list=()
  if [[ $# -eq 1 ]]; then
    local list_name="$1"
    if declare -p "${list_name}" 2>/dev/null | grep -q 'declare -a'; then
      eval "install_list=(\"\${${list_name}[@]}\")"
    else
      install_list=("${list_name}")
    fi
  else
    install_list=("$@")
  fi

  if ! command -v brew >/dev/null 2>&1; then
    echo "brew not found. Please install Homebrew first."
    return 1
  fi

  local GREEN='' YELLOW='' RED='' BOLD='' RESET=''
  if [[ -t 1 ]]; then
    GREEN='\033[0;32m'
    YELLOW='\033[0;33m'
    RED='\033[0;31m'
    BOLD='\033[1m'
    RESET='\033[0m'
  fi

  local -a success_list=()
  local -a failure_list=()

  for tool in "${install_list[@]}"; do
    if is_installed "${tool}"; then
      local version
      version="$(get_brew_version "${tool}")"
      printf "${GREEN}✓ Already installed: ${tool} (${version})${RESET}\n"
      success_list+=("${tool}@${version}")
      continue
    fi

    printf "${YELLOW}→ Installing: ${tool}${RESET}\n"
    if brew install "${tool}"; then
      local version
      version="$(get_brew_version "${tool}")"
      printf "${GREEN}✓ Installed: ${tool} (${version})${RESET}\n"
      success_list+=("${tool}@${version}")
    else
      printf "${RED}✗ Failed: ${tool}${RESET}\n"
      failure_list+=("${tool}")
    fi
  done

  printf "\n${BOLD}Install summary:${RESET}\n"
  printf "  ${GREEN}Success: ${#success_list[@]}${RESET}\n"
  if [[ ${#success_list[@]} -gt 0 ]]; then
    printf "  ${GREEN}Success list: ${success_list[*]}${RESET}\n"
  fi
  if [[ ${#failure_list[@]} -gt 0 ]]; then
    printf "  ${RED}Failed: ${#failure_list[@]}${RESET}\n"
    printf "  ${RED}Failed list: ${failure_list[*]}${RESET}\n"
    return 1
  else
    printf "  ${YELLOW}Failed: 0${RESET}\n"
  fi

  return 0
}


# 入口函数
function main() {
  install_tools brew_install_list
  exit $?
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main
fi
