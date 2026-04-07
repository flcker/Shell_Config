################################################################################
# 需要在 "~/.zshrc" 中调用
################################################################################

# config dir vars
ZSH_CONFIG_DIR="${ZSH:-$HOME/.config/zsh}"
ZSH_CONFIG_STARSHIP_DIR="$ZSH_CONFIG_DIR/submodule/starship"
ZSH_CONFIG_NVIM_DIR="$ZSH_CONFIG_DIR/submodule/nvim"

# module loader
ZSH_MODULE_DIR="$HOME/.config/zsh/zsh"

for config_file in "$ZSH_MODULE_DIR"/*.zsh; do
  if [[ -f "$config_file" ]]; then
    source "$config_file"
  fi
done
