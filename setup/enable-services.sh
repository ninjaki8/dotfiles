#!/bin/bash

# Systemd Service Enabler Script
# Enables specified systemd services with proper error handling and reporting

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
SUCCESS_COUNT=0
FAILED_COUNT=0
ALREADY_ENABLED_COUNT=0

# Arrays to store results
SUCCESSFUL_SERVICES=()
FAILED_SERVICES=()
ALREADY_ENABLED_SERVICES=()

# Define services to enable
# Format: "service_name:type" where type is either "system" or "user"
SERVICES=(
    "bluetooth:system"
    "ly:system"
    "hyprpaper:user"
    "hyprpolkitagent:user"
    "waybar:user"
)

echo -e "${BLUE}=== Systemd Service Enabler ===${NC}"
echo -e "${BLUE}Enabling specified systemd services...${NC}\n"

# Function to enable a service
enable_service() {
    local service="$1"
    local type="$2"
    
    echo -e "${BLUE}Processing: $service ($type)${NC}"
    
    if [[ "$type" == "user" ]]; then
        # Check if user service is already enabled
        if systemctl --user is-enabled "$service" &>/dev/null; then
            local status=$(systemctl --user is-enabled "$service")
            if [[ "$status" == "enabled" ]]; then
                echo -e "${YELLOW}⚠ Already enabled: $service${NC}"
                ALREADY_ENABLED_SERVICES+=("$service (user)")
                ((ALREADY_ENABLED_COUNT++))
                return
            fi
        fi
        
        # Try to enable user service
        if systemctl --user enable "$service" &>/dev/null; then
            echo -e "${GREEN}✓ Successfully enabled: $service (user)${NC}"
            SUCCESSFUL_SERVICES+=("$service (user)")
            ((SUCCESS_COUNT++))
        else
            echo -e "${RED}✗ Failed to enable: $service (user)${NC}"
            FAILED_SERVICES+=("$service (user)")
            ((FAILED_COUNT++))
        fi
    else
        # Check if system service is already enabled
        if systemctl is-enabled "$service" &>/dev/null; then
            local status=$(systemctl is-enabled "$service")
            if [[ "$status" == "enabled" ]]; then
                echo -e "${YELLOW}⚠ Already enabled: $service${NC}"
                ALREADY_ENABLED_SERVICES+=("$service (system)")
                ((ALREADY_ENABLED_COUNT++))
                return
            fi
        fi
        
        # Try to enable system service
        if sudo systemctl enable "$service" &>/dev/null; then
            echo -e "${GREEN}✓ Successfully enabled: $service (system)${NC}"
            SUCCESSFUL_SERVICES+=("$service (system)")
            ((SUCCESS_COUNT++))
        else
            echo -e "${RED}✗ Failed to enable: $service (system)${NC}"
            FAILED_SERVICES+=("$service (system)")
            ((FAILED_COUNT++))
        fi
    fi
    
    echo # Empty line for readability
}

# Process each service
for service_entry in "${SERVICES[@]}"; do
    IFS=':' read -r service_name service_type <<< "$service_entry"
    enable_service "$service_name" "$service_type"
done

# Print summary
echo -e "${BLUE}=== Service Enablement Summary ===${NC}"
echo -e "${GREEN}Successfully enabled: $SUCCESS_COUNT services${NC}"
echo -e "${YELLOW}Already enabled: $ALREADY_ENABLED_COUNT services${NC}"
echo -e "${RED}Failed to enable: $FAILED_COUNT services${NC}"
echo -e "${BLUE}Total services processed: $((SUCCESS_COUNT + FAILED_COUNT + ALREADY_ENABLED_COUNT))${NC}"

# Print detailed results
if [[ $SUCCESS_COUNT -gt 0 ]]; then
    echo -e "\n${GREEN}Successfully enabled services:${NC}"
    printf '%s\n' "${SUCCESSFUL_SERVICES[@]}"
fi

if [[ $ALREADY_ENABLED_COUNT -gt 0 ]]; then
    echo -e "\n${YELLOW}Already enabled services:${NC}"
    printf '%s\n' "${ALREADY_ENABLED_SERVICES[@]}"
fi

if [[ $FAILED_COUNT -gt 0 ]]; then
    echo -e "\n${RED}Failed to enable services:${NC}"
    printf '%s\n' "${FAILED_SERVICES[@]}"
    echo -e "\n${YELLOW}Note: Some services might not be installed or available on your system${NC}"
fi

# Additional information
echo -e "\n${BLUE}=== Additional Information ===${NC}"
echo -e "${BLUE}System services are enabled system-wide and start at boot${NC}"
echo -e "${BLUE}User services are enabled for the current user and start when the user logs in${NC}"

# Start services that were successfully enabled (optional)
echo -e "\n${YELLOW}Would you like to start the successfully enabled services now? (y/N)${NC}"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    echo -e "\n${BLUE}Starting enabled services...${NC}"
    
    for service_entry in "${SERVICES[@]}"; do
        IFS=':' read -r service_name service_type <<< "$service_entry"
        
        if [[ "$service_type" == "user" ]]; then
            if systemctl --user is-enabled "$service_name" &>/dev/null; then
                if systemctl --user start "$service_name" &>/dev/null; then
                    echo -e "${GREEN}✓ Started: $service_name (user)${NC}"
                else
                    echo -e "${RED}✗ Failed to start: $service_name (user)${NC}"
                fi
            fi
        else
            if systemctl is-enabled "$service_name" &>/dev/null; then
                if sudo systemctl start "$service_name" &>/dev/null; then
                    echo -e "${GREEN}✓ Started: $service_name (system)${NC}"
                else
                    echo -e "${RED}✗ Failed to start: $service_name (system)${NC}"
                fi
            fi
        fi
    done
fi

# Exit with appropriate code
if [[ $FAILED_COUNT -gt 0 ]]; then
    exit 1
else
    echo -e "\n${GREEN}Service enablement completed successfully!${NC}"
    exit 0
fi