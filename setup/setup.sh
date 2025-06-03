#!/bin/bash

# Arch Linux Package Installer Script
# Reads packages from packages.txt and installs them with error reporting

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
SUCCESS_COUNT=0
FAILED_COUNT=0
NOT_FOUND_COUNT=0

# Arrays to store results
SUCCESSFUL_PACKAGES=()
FAILED_PACKAGES=()
NOT_FOUND_PACKAGES=()

# Check if packages.txt exists
if [[ ! -f "packages.txt" ]]; then
    echo -e "${RED}Error: packages.txt not found in current directory${NC}"
    exit 1
fi

# Check if file is empty
if [[ ! -s "packages.txt" ]]; then
    echo -e "${YELLOW}Warning: packages.txt is empty${NC}"
    exit 0
fi

echo -e "${BLUE}=== Arch Linux Package Installer ===${NC}"
echo -e "${BLUE}Reading packages from packages.txt...${NC}\n"

# Update package database first
echo -e "${BLUE}Updating package database...${NC}"
if sudo pacman -Sy; then
    echo -e "${GREEN}Package database updated successfully${NC}\n"
else
    echo -e "${RED}Failed to update package database${NC}\n"
fi

# Read packages from file and process them
while IFS= read -r package || [[ -n "$package" ]]; do
    # Skip empty lines and comments
    [[ -z "$package" || "$package" =~ ^[[:space:]]*# ]] && continue
    
    # Remove leading/trailing whitespace
    package=$(echo "$package" | xargs)
    
    echo -e "${BLUE}Installing: $package${NC}"
    
    # Check if package exists in repositories
    if pacman -Ss "^$package$" &>/dev/null; then
        # Try to install the package
        if sudo pacman -S --noconfirm "$package"; then
            echo -e "${GREEN}✓ Successfully installed: $package${NC}"
            SUCCESSFUL_PACKAGES+=("$package")
            ((SUCCESS_COUNT++))
        else
            echo -e "${RED}✗ Failed to install: $package${NC}"
            FAILED_PACKAGES+=("$package")
            ((FAILED_COUNT++))
        fi
    else
        echo -e "${YELLOW}✗ Package not found in repositories: $package${NC}"
        NOT_FOUND_PACKAGES+=("$package")
        ((NOT_FOUND_COUNT++))
    fi
    
    echo # Empty line for readability
done < "packages.txt"

# Print summary
echo -e "${BLUE}=== Installation Summary ===${NC}"
echo -e "${GREEN}Successfully installed: $SUCCESS_COUNT packages${NC}"
echo -e "${RED}Failed to install: $FAILED_COUNT packages${NC}"
echo -e "${YELLOW}Not found in repositories: $NOT_FOUND_COUNT packages${NC}"
echo -e "${BLUE}Total packages processed: $((SUCCESS_COUNT + FAILED_COUNT + NOT_FOUND_COUNT))${NC}"

# Print detailed results if there are failures or not found packages
if [[ $FAILED_COUNT -gt 0 ]]; then
    echo -e "\n${RED}Failed packages:${NC}"
    printf '%s\n' "${FAILED_PACKAGES[@]}"
fi

if [[ $NOT_FOUND_COUNT -gt 0 ]]; then
    echo -e "\n${YELLOW}Packages not found in repositories:${NC}"
    printf '%s\n' "${NOT_FOUND_PACKAGES[@]}"
fi

if [[ $SUCCESS_COUNT -gt 0 ]]; then
    echo -e "\n${GREEN}Successfully installed packages:${NC}"
    printf '%s\n' "${SUCCESSFUL_PACKAGES[@]}"
fi

# Exit with appropriate code
if [[ $FAILED_COUNT -gt 0 || $NOT_FOUND_COUNT -gt 0 ]]; then
    exit 1
else
    echo -e "\n${GREEN}All packages installed successfully!${NC}"
    exit 0
fi