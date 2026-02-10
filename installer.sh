#!/bin/bash

# Define paths at the start so we don't get lost
BASE_DIR="$HOME/dotterfiles"
DOTS_DIR="$BASE_DIR/.dots"

# Pacman Packages
PACKAGES="hyprlock wofi waybar kitty noto-fonts ttf-bitstream-vera git base-devel cliphist hyprland hyprpaper hyprcursor hyprsunset hyprpolkitagent xdg-desktop-portal-hyprland pipewire pipewire-pulse pipewire-alsa wireplumber pipewire-jack npm wireguard"

# Yay Packages
Yay_PACKAGES="ttf-nerd-fonts-symbols python-hijri-converter rose-pine-hyprcursor mov-cli ani-cli python-mov-cli-youtube"

# Installing Pacman packages
sudo pacman -Sy --needed $PACKAGES && echo "Base successfully installed."

# Clone Git Repo
read -p "Cloning git repo, what ya say? (y/n): " gitans
if [[ "$gitans" =~ ^[Yy]$ ]]; then
    echo "cloning repo to $BASE_DIR"
    git clone https://github.com/falafelvendor/dotterfiles "$BASE_DIR"
    
    mkdir -p "$DOTS_DIR"
    # Moving specific folders into .dots inside the repo
    mv "$BASE_DIR/dotfiles/hypr/" "$DOTS_DIR/"
    mv "$BASE_DIR/dotfiles/waybar/" "$DOTS_DIR/"
    mv "$BASE_DIR/dotfiles/kitty/" "$DOTS_DIR/"
    mv "$BASE_DIR/dotfiles/fontconfig/" "$DOTS_DIR/"
    mv "$BASE_DIR/dotfiles/neofetch/" "$DOTS_DIR/"
    mv "$BASE_DIR/dotfiles/wofi/" "$DOTS_DIR/"
    mv "$BASE_DIR/dotfiles/NetworkManager/" "$DOTS_DIR/"
    mv "$BASE_DIR/dotfinstall.sh" "$DOTS_DIR/"
    chmod +x "$DOTS_DIR/dotfinstall.sh"
else
    echo "git repo skip: Caution, following steps might fail if files are missing."
fi 

# Copy .bashrc / .zshrc
# We use -f to check if the file exists in the repo before copying
read -p "replace .bashrc? (Y/N): " bashrcans
if [[ "$bashrcans" =~ ^[Yy]$ ]]; then
    [ -f "$BASE_DIR/.bashrc" ] && cp "$HOME/.bashrc" "$HOME/.bashrc.bak" && cp "$BASE_DIR/.bashrc" "$HOME/.bashrc"
elif [[ "$bashrcans" =~ ^[Nn]$ ]]; then
    read -p "replace .zshrc? (Y/n) " zshrcans
    if [[ "$zshrcans" =~ ^[Yy]$ ]]; then
        [ -f "$BASE_DIR/.zshrc" ] && cp "$HOME/.zshrc" "$HOME/.zshrc.bak" && cp "$BASE_DIR/.zshrc" "$HOME/.zshrc"
    fi
fi

# Copy Dotfiles (Running your sub-script)
read -p "copy dotfiles? (y/n): " copyans
if [[ "$copyans" =~ ^[Yy]$ ]]; then
    cd "$DOTS_DIR" && ./dotfinstall.sh
fi

# Install Yay
if ! command -v yay &> /dev/null; then
    read -p "Install yay? (y/n): " yayinstallans
    if [[ "$yayinstallans" =~ ^[Yy]$ ]]; then
        git clone https://aur.archlinux.org/yay.git "$HOME/yay"
        cd "$HOME/yay" && makepkg -si
    fi
fi

# Install Yay packages
read -p "Install yay packages? (y/n): " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
    yay -S $Yay_PACKAGES
fi

# Install Wireguard (The part you were working on)
read -p "install wireguard configs? /etc/wireguard/* ? (y/n): " wga 
if [[ "$wga" =~ ^[Yy]$ ]]; then
    # Assuming your wg configs are in your repo's wireguard folder
    if [ -d "$BASE_DIR/wireguard" ]; then
        echo "installing wireguard configs..."
        sudo cp -r "$BASE_DIR/wireguard/"* /etc/wireguard/
        sudo chmod 600 /etc/wireguard/*.conf
        echo "Configs copied to /etc/wireguard/"
    else
        echo "Error: Wireguard folder not found in $BASE_DIR"
    fi
fi

# Restart system?
read -p "Finished. Restart System? (Y/N): " restartanswer
if [[ "$restartanswer" =~ ^[Yy]$ ]]; then
    reboot
fi
