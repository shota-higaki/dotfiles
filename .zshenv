# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Editor (非対話シェルでも $EDITOR が必要な場面があるため .zshenv に置く)
export EDITOR="code --wait"
