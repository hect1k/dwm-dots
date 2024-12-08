#!/bin/bash

# Create standard directories
mkdir -p ~/desk ~/dl ~/dox ~/pub ~/vids ~/work ~/music ~/tmplts ~/pix/ss ~/pix/walls

# Install yay if not installed
if ! type "yay" &>/dev/null; then
    git clone --depth=1 https://aur.archlinux.org/yay.git
    cd yay || exit
    makepkg -si
    cd ..
    rm -rf yay
fi

# Package groups
base=("base" "linux" "linux-firmware" "base-devel")
graphics=("intel-media-driver" "mesa" "xf86-video-amdgpu" "xf86-video-vmware" "xf86-video-ati" "xf86-video-nouveau" "libva-intel-driver" "vulkan-intel" "libva-mesa-driver" "vulkan-radeon" "nvidia" "nvidia-utils" "lib32-nvidia-utils")
xorg=("xorg-server" "xorg-xinit" "xdg-utils" "xorg-xinput" "xorg-xrandr")
editors=("vi" "vim" "neovim")
utils=("htop" "wget" "curl" "openssh" "wireless_tools" "smartmontools" "wpa_supplicant" "iwd" "p7zip" "auto-cpufreq" "man" "man-db" "man-pages" "ripgrep" "flatpak" "linux-headers" "v4l2loopback-dkms"  "xdg-desktop-portal-gtk" "ueberzug" "xdotool" "ncdu" "mpd" "mpv" "bluez" "bluez-libs" "bluez-utils" "xclip" "xcolor" "rsync" "git" "pulsemixer" "playerctl" "blueman" "maim" "unzip" "zip" "brightnessctl" "ntfs-3g" "udisks2" "udiskie" "gvfs" "mlocate" "libnotify" "jq" "acpi" "sxiv" "pass" "feh" "fzf" "pipewire" "pipewire-pulse" "networkmanager" "neofetch" "picom" "xidlehook" "xorg-xsetroot" "lsof" "downgrade" "gptfdisk")
shell=("dash" "zsh" "zsh-syntax-highlighting" "lxsession")
appearance=("gruvbox-dark-gtk" "gruvbox-dark-icons-gtk")
fonts=("ttf-joypixels" "ttf-jetbrains-mono-nerd" "ttf-ms-fonts" "noto-fonts-emoji")
dev=("nodejs" "npm" "pnpm" "go" "lua" "python" "python-pip")
apps=("onlyoffice-bin" "yt-dlp" "silicon" "arandr" "dunst" "github-cli" "librewolf-bin" "chromium" "pcmanfm" "zathura" "zathura-pdf-mupdf" "ytfzf" "ani-cli")

# Function to install packages
install_packages() {
    local programs=("$@")
    for program in "${programs[@]}"; do
        if ! yay -Q "$program" >/dev/null 2>&1; then
            echo "Installing $program..."
            yay -S --noconfirm "$program"
            echo "$program installed successfully!"
        else
            echo "$program already installed."
        fi
    done
}

# Install packages
install_packages "${graphics[@]}"
install_packages "${xorg[@]}"
install_packages "${editors[@]}"
install_packages "${utils[@]}"
install_packages "${shell[@]}"
install_packages "${appearance[@]}"
install_packages "${fonts[@]}"
install_packages "${dev[@]}"
install_packages "${apps[@]}"

# Install dwm
if ! type "dwm" &>/dev/null; then
    git clone --depth=1 https://github.com/nnisarggada/dwm
    cd dwm || exit
    sudo make clean install
    cd ..
    rm -rf dwm
fi

# Install dmenu
if ! type "dmenu" &>/dev/null; then
    git clone --depth=1 https://github.com/nnisarggada/dmenu
    cd dmenu || exit
    sudo make clean install
    cd ..
    rm -rf dmenu
fi

# Install st
if ! type "st" &>/dev/null; then
    git clone --depth=1 https://github.com/nnisarggada/st
    cd st || exit
    sudo make clean install
    cd ..
    rm -rf st
fi

# Install slock
if ! type "slock" &>/dev/null; then
    git clone --depth=1 https://github.com/nnisarggada/slock
    cd slock || exit
    sudo make clean install
    cd ..
    rm -rf slock
fi

# Apply system settings
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
sudo usermod -aG input "$USER"

# Enable system services
systemctl --user enable mpd
sudo systemctl enable bluetooth
sudo systemctl enable NetworkManager

# Load kernel module
sudo modprobe v4l2loopback

# Copy local files
sudo cp -r .config ~/
sudo cp -r .local ~/
sudo cp -r pix/ ~/
sudo cp -r xorg.conf.d /etc/X11/
sudo cp .zshrc ~/
sudo cp .xinitrc ~/
sudo cp .gtkrc-2.0 ~/

sudo rm -rf ~/.config/nvim && git clone --depth=1 https://github.com/nnisarggada/nvim-config ~/.config/nvim/

pnpm setup

# Install and configure auto-cpufreq
sudo auto-cpufreq --install

# Fix permissions and set shell
sudo chown "$USER" ~/ -R
sudo rm -rf /bin/sh
sudo ln -s /usr/bin/dash /bin/sh
chsh -s /usr/bin/zsh
