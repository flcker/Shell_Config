# 需要在 "~/.zshrc" 中调用

################################################################################
# module loader
ZSH_MODULE_DIR="$HOME/.config/zsh/zsh"

for config_file in "$ZSH_MODULE_DIR"/*.zsh; do
  if [[ -f "$config_file" ]]; then
    source "$config_file"
  fi
done
