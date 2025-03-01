#!/bin/bash
set -e  # Exit on error

echo "🔄 Starting cleanup process on Arch Linux..."

##############################
# 1. Docker Cleanup
##############################
if command -v docker &> /dev/null; then
    if systemctl is-active --quiet docker; then
        echo "🧹 Cleaning Docker resources..."
        sudo docker system prune -a --volumes -f
        sudo docker system df
    else
        echo "⚠️ Docker is installed but not running. Skipping cleanup..."
    fi
else
    echo "⚠️ Docker is not installed. Skipping cleanup..."
fi

##############################
# 2. PM2 Logs Cleanup
##############################
if command -v pm2 &> /dev/null; then
    echo "🧹 Cleaning PM2 logs..."
    sudo pm2 flush
    if [ -f ~/.pm2/dump.pm2 ]; then
        echo "🗑 Removing PM2 dump file..."
        sudo rm -f ~/.pm2/dump.pm2
    fi
else
    echo "⚠️ PM2 not installed, skipping..."
fi

##############################
# 3. Pacman & Yay Cache Cleanup
##############################
echo "🧹 Cleaning Pacman and Yay cache..."
sudo pacman -Scc --noconfirm  # Clears all cached package files
if command -v yay &> /dev/null; then
    yay -Sc --noconfirm
else
    echo "⚠️ yay not installed, skipping..."
fi
if command -v paru &> /dev/null; then
    paru -Sc --noconfirm
else
    echo "⚠️ paru not installed, skipping..."
fi
echo "🔍 Checking for orphaned packages..."
if pacman -Qqdt &>/dev/null; then
    orphans=$(pacman -Qqdt)  
    echo "🧹 Removing orphaned packages..."
    echo "$orphans" | xargs sudo pacman -Rns --noconfirm
else  
    echo "✅ No orphaned packages found. Skipping removal."
fi

##############################
# 4. pnpm Cache Cleanup
##############################
if command -v pnpm &> /dev/null; then
    echo "🧹 Cleaning pnpm cache..."
    pnpm store prune
    CACHE_PATHS=( "~/.cache/pnpm" "~/.npm/_cache" "~/.yarn/cache" )
    for cache in "${CACHE_PATHS[@]}"; do
        eval cache_path=$cache
        if [ -d "$cache_path" ]; then
            echo "🗑 Removing cache directory: $cache_path"
            sudo rm -rf "$cache_path"
        fi
    done
else
    echo "⚠️ pnpm not installed, skipping..."
fi

##############################
# 5. Journal Logs Cleanup
##############################
echo "🧹 Cleaning journal logs..."
sudo journalctl --vacuum-size=100M

##############################
# 6. Check Large Files
##############################
echo "🔍 Listing top 20 largest files/directories in root:"
sudo du -ah / 2>/dev/null | sort -rh | head -n 20

echo "✅ Cleanup complete!"
