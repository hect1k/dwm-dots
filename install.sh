#!/bin/bash

echo "Welcome to the Nnisarg's Arch Linux + Suckless Setup Script!"

# Check for --no-confirm flag
NO_CONFIRM=false
if [[ "$1" == "--no-confirm" ]]; then
    NO_CONFIRM=true
fi

# Function for interactive confirmation
confirm() {
    if [[ $NO_CONFIRM == true ]]; then
        return 0
    fi
    while true; do
        read -rp "$1 [Y/n]: " yn
        case $yn in
            [Nn]*) return 1 ;;
            *) return 0 ;;
        esac
    done
}

# Create standard directories
if confirm "Do you want to create standard directories?"; then
    echo "Creating standard directories..."
    mkdir -p ~/desk ~/dl ~/dox ~/pub ~/vids ~/work ~/music ~/tmplts ~/pix/ss ~/pix/walls
    echo "Directories created."
fi

# Install yay if not installed
if ! type "yay" &>/dev/null; then
    if confirm "yay is not installed. Do you want to install it?"; then
        git clone --depth=1 https://aur.archlinux.org/yay.git
        cd yay || exit
        makepkg -si
        cd ..
        rm -rf yay
    else
        echo "yay installation skipped. This script requires yay to proceed."
        exit 1
    fi
fi

# Define package groups
declare -A mandatory_package_groups=(
    ["Base"]="base linux linux-firmware base-devel"
    ["Graphics"]="intel-media-driver mesa xf86-video-amdgpu xf86-video-vmware xf86-video-ati xf86-video-nouveau libva-intel-driver vulkan-intel libva-mesa-driver vulkan-radeon nvidia nvidia-utils lib32-nvidia-utils"
    ["Xorg"]="xorg-server xorg-xinit xdg-utils xorg-xinput xorg-xrandr"
    ["Editors"]="vi vim neovim"
    ["Utils"]="htop wget curl openssh wireless_tools smartmontools wpa_supplicant iwd p7zip auto-cpufreq man man-db man-pages ripgrep flatpak linux-headers v4l2loopback-dkms xdg-desktop-portal-gtk ueberzug xdotool ncdu mpd mpv bluez bluez-libs bluez-utils xclip xcolor rsync git pulsemixer playerctl blueman maim unzip zip brightnessctl ntfs-3g udisks2 udiskie gvfs mlocate libnotify jq acpi sxiv pass feh fzf pipewire pipewire-pulse networkmanager neofetch picom xidlehook xorg-xsetroot lsof downgrade gptfdisk imagemagick"
    ["Shell"]="dash zsh zsh-syntax-highlighting lxsession"
    ["Apps"]="silicon arandr dunst librewolf-bin firefox chromium pcmanfm zathura zathura-pdf-mupdf"
)

declare -A optional_package_groups=(
    ["Appearance"]="gruvbox-dark-gtk gruvbox-dark-icons-gtk"
    ["Fonts"]="ttf-joypixels ttf-jetbrains-mono-nerd ttf-ms-fonts noto-fonts noto-fonts-cjk noto-fonts-extra noto-fonts-emoji ttf-fira-code ttf-dejavu ttf-liberation ttf-indic-otf"
    ["Development"]="nodejs npm pnpm go lua python python-pip"
    ["Apps"]="onlyoffice-bin yt-dlp github-cli ytfzf ani-cli gimp gimp-plugin-saveforweb"
    ["Misc"]="cpig-git"
)

# Install packages
for group in "${!mandatory_package_groups[@]}"; do
    for pkg in ${mandatory_package_groups[$group]}; do
        if ! yay -Q "$pkg" &>/dev/null; then
            echo "Installing $pkg..."
            yay -S --noconfirm "$pkg"
        else
            echo "$pkg is already installed."
        fi
    done
done

for group in "${!optional_package_groups[@]}"; do
    echo "Processing $group packages..."
    for pkg in ${optional_package_groups[$group]}; do
        if confirm "Do you want to install $pkg?"; then
            if ! yay -Q "$pkg" &>/dev/null; then
                echo "Installing $pkg..."
                yay -S --noconfirm "$pkg"
            else
                echo "$pkg is already installed."
            fi
        else
            echo "Skipping $pkg."
        fi
    done
done

# Clone and install suckless software
suckless_repos=("dwm" "dmenu" "st" "slock")
for repo in "${suckless_repos[@]}"; do
    if confirm "Do you want to install Nnisarg's $repo?"; then
        rm -rf ~/.config/$repo
        git clone --depth=1 "https://github.com/nnisarggada/$repo" ~/.config/$repo
        cd ~/.config/$repo || exit
        sudo make clean install
        cd -
    else
        echo "Skipping $repo installation."
    fi
done

# Nnisarg's nvim config
if confirm "Do you want to install Nnisarg's nvim config?"; then
    rm -rf ~/.config/nvim
    git clone --depth=1 "https://github.com/nnisarggada/nvim-config" ~/.config/nvim
fi

# System settings
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    sudo usermod -aG input "$USER"

# Enable system services
    systemctl --user enable mpd
    sudo systemctl enable bluetooth
    sudo systemctl enable NetworkManager

# Load kernel module
sudo modprobe v4l2loopback

# Copy local files
if confirm "Do you want to copy local configuration files?"; then
    sudo cp -r .config ~/
    sudo cp -r .local ~/
    sudo cp -r pix/ ~/
    sudo cp -r xorg.conf.d /etc/X11/
    sudo cp .zshrc ~/
    sudo cp .xinitrc ~/
    sudo cp .gtkrc-2.0 ~/
fi

# Install and configure auto-cpufreq
sudo auto-cpufreq --install

# Fix permissions and set shell
sudo chown "$USER" ~/ -R
sudo rm -rf /bin/sh
sudo ln -s /usr/bin/dash /bin/sh
chsh -s /usr/bin/zsh

echo "Setup complete! Reboot your system to apply changes."
