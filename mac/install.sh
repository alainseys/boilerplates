#!/bin/bash

echo "Installing Xcode..."
xcode-select --install
echo "Installing Homebrew..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo "Updateing Homebrew..."
homebrew update

brew install --cask spectacle
brew install --cask alfred
brew install --cask visual-studio-code
brew install --cask postman
brew install --cask dozer
brew install google-chrome
brew install --cask brave-browser
brew install --cask authy
brew install --cask vlc
brew install --cask iterm2
brew install --cask wget
brew install --cask docker
brew install --cask cyberduck
brew install --cask composer
brew install --cask sequel-pro
brew install --cask teamviewer
brew install --cask slack

echo "Change Directory to $HOME"
cd $HOME
echo "Cloning Config repo..."
git clone https://github.com/alainseys/mac-setup.git
cd mac-setup
cp .zshrc ~/.zshrc
echo "Install completed"