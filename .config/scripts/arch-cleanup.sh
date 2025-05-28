#!/bin/bash
set -e

# --------------------[ Colors ]--------------------
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
BOLD='\033[1m'
RESET='\033[0m'

# --------------------[ Root Check ]--------------------
if [ "$EUID" -eq 0 ]; then
  echo -e "\n${RED}${BOLD}✖ Do not run this script as root. Use your regular user.${RESET}\n"
  exit 1
fi

# --------------------[ Helper ]--------------------
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# --------------------[ Start ]--------------------
echo -e "\n${BOLD}${BLUE}=== Starting Arch Linux Cleanup ===${RESET}\n"

# --------------------[ Orphan Removal (pacman) ]--------------------
echo -e "${BLUE}${BOLD}[INFO]${RESET}${BLUE} Removing orphaned packages (pacman)${RESET}"
if command_exists pacman; then
  set +e
  orphans=$(pacman -Qdtq)
  set -e

  if [ -n "$orphans" ]; then
    echo -e "${YELLOW}${BOLD}==>${RESET}${YELLOW} Orphans found: $orphans${RESET}"
    echo "$orphans" | xargs -r sudo pacman -Rns --noconfirm
    echo -e "${GREEN}${BOLD}==>${RESET}${GREEN} Orphans removed successfully.${RESET}"
  else
    echo -e "${GREEN}${BOLD}==>${RESET}${GREEN} No orphaned packages found.${RESET}"
  fi
else
  echo -e "${RED}${BOLD}==>${RESET}${RED} pacman not found. Skipping orphan removal.${RESET}"
fi

echo ""

# --------------------[ Yay Cache Cleanup ]--------------------
echo -e "${BLUE}${BOLD}[INFO]${RESET}${BLUE} Cleaning yay cache${RESET}"
if command_exists yay; then
  yay -Sc --noconfirm
else
  echo -e "${YELLOW}${BOLD}==>${RESET}${YELLOW} yay not found. Skipping yay cache cleanup.${RESET}"
fi

echo ""

# --------------------[ Pacman Cache Cleanup ]--------------------
echo -e "${BLUE}${BOLD}[INFO]${RESET}${BLUE} Cleaning pacman cache${RESET}"
if command_exists paccache; then
  sudo paccache -r
  sudo paccache -ruk0
else
  echo -e "${YELLOW}${BOLD}==>${RESET}${YELLOW} paccache not found. Install 'pacman-contrib' to enable cache pruning.${RESET}"
fi

echo ""

# --------------------[ Flatpak Cleanup ]--------------------
echo -e "${BLUE}${BOLD}[INFO]${RESET}${BLUE} Cleaning Flatpak cache${RESET}"
if command_exists flatpak; then
  flatpak uninstall --unused -y
  flatpak remove --unused -y
  echo -e "${GREEN}${BOLD}==>${RESET}${GREEN} Flatpak unused apps and runtimes removed.${RESET}"
else
  echo -e "${YELLOW}${BOLD}==>${RESET}${YELLOW} flatpak not found. Skipping Flatpak cleanup.${RESET}"
fi

echo ""

# --------------------[ Journal Cleanup ]--------------------
echo -e "${BLUE}${BOLD}[INFO]${RESET}${BLUE} Cleaning journal logs (older than 7 days)${RESET}"
if command_exists journalctl; then
  sudo journalctl --vacuum-time=7d
  echo -e "${GREEN}${BOLD}==>${RESET}${GREEN} Old journal logs removed.${RESET}"
else
  echo -e "${YELLOW}${BOLD}==>${RESET}${YELLOW} journalctl not found. Skipping journal cleanup.${RESET}"
fi

echo ""

# --------------------[ Log File Cleanup ]--------------------
echo -e "${BLUE}${BOLD}[INFO]${RESET}${BLUE} Trimming log files in /var/log${RESET}"
if [ -d /var/log ]; then
  sudo find /var/log -type f -name "*.log" -exec truncate -s 0 {} \;
  echo -e "${GREEN}${BOLD}==>${RESET}${GREEN} Log files truncated.${RESET}"
else
  echo -e "${YELLOW}${BOLD}==>${RESET}${YELLOW} /var/log not found. Skipping log cleanup.${RESET}"
fi

echo ""

# --------------------[ Done ]--------------------
echo -e "${BOLD}${BLUE}=== Arch Linux cleanup complete! ===${RESET}"
