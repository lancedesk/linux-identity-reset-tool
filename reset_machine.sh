#!/bin/bash
# ===============================================================
#  Cursor & System Fingerprint Reset Script (Enhanced)
#  - Cleans Cursor configs & history
#  - Regenerates machine-id & boot-id
#  - Randomizes MAC address & hostname
#  - Supports Undo (restores original machine-id, MAC, hostname)
#  - Added: Root privilege check, dry-run mode, enhanced backup
# ===============================================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

BACKUP_FILE="$HOME/.fingerprint_reset_backup"
DRY_RUN=false

# Check if running with proper privileges
check_privileges()
{
    if [[ "$DRY_RUN" == true ]]; then
        return 0
    fi
    
    if [[ $EUID -eq 0 ]]; then
        echo -e "${YELLOW}[!] Running as root. All operations will be performed directly.${NC}"
        return 0
    fi
    
    # Check if user can sudo
    if ! sudo -n true 2>/dev/null; then
        echo -e "${RED}[!] This script requires sudo privileges for system changes.${NC}"
        echo -e "${RED}    Please run with sudo or ensure your user can sudo without password.${NC}"
        echo -e "${YELLOW}    Alternatively, use --dry-run to see what would be changed.${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}[✓] Sudo privileges confirmed${NC}"
}

# Random hostname generator
generate_random_hostname()
{
    echo "host-$(tr -dc 'a-z0-9' </dev/urandom | head -c8)"
}

# Display system fingerprints
show_fingerprints()
{
    echo -e "${BLUE}=== Current System Fingerprints ===${NC}"
    echo -e "${YELLOW}Machine ID:${NC} $(cat /etc/machine-id 2>/dev/null || echo 'Not found')"
    echo -e "${YELLOW}Boot ID:${NC} $(cat /proc/sys/kernel/random/boot_id 2>/dev/null || echo 'Not found')"
    echo -e "${YELLOW}Hostname:${NC} $(hostname)"
    echo -e "${YELLOW}Hostname file:${NC} $(cat /etc/hostname 2>/dev/null || echo 'Not found')"
    echo -e "${YELLOW}MAC Addresses:${NC}"
    ip link show | awk '/ether/ {print "  " $2}'
    echo -e "${YELLOW}DBus ID:${NC} $(dbus-uuidgen --get 2>/dev/null || echo 'Not available')"
    echo -e "${YELLOW}D-Bus machine ID:${NC} $(cat /var/lib/dbus/machine-id 2>/dev/null || echo 'Not found')"
    echo -e "${BLUE}==================================${NC}"
}

# Save original state (enhanced backup)
backup_originals()
{
    if [[ "$DRY_RUN" == true ]]; then
        echo -e "${PURPLE}[DRY-RUN] Would save backup to: $BACKUP_FILE${NC}"
        return 0
    fi
    
    echo -e "${GREEN}[+] Saving original system state...${NC}"
    
    # Create comprehensive backup
    {
        echo "# Fingerprint Reset Backup - $(date)"
        echo "HOSTNAME=$(hostname)"
        
        if [[ -f /etc/hostname ]]; then
            echo "ETC_HOSTNAME=$(cat /etc/hostname)"
        fi
        
        if [[ -f /etc/machine-id ]]; then
            echo "MACHINE_ID=$(cat /etc/machine-id)"
        fi
        
        if [[ -f /var/lib/dbus/machine-id ]]; then
            echo "DBUS_MACHINE_ID=$(cat /var/lib/dbus/machine-id)"
        fi
        
        # Backup original D-Bus UUID if available
        if command -v dbus-uuidgen >/dev/null 2>&1; then
            dbus_uuid=$(dbus-uuidgen --get 2>/dev/null)
            if [[ -n "$dbus_uuid" ]]; then
                echo "DBUS_UUID=$dbus_uuid"
            fi
        fi
        
    } > "$BACKUP_FILE"

    # Save MAC addresses for all non-loopback interfaces
    ip link show | awk -F: '$1 ~ /^[0-9]+$/ {print $2}' | tr -d ' ' | while read -r iface; do
        if [[ "$iface" != "lo" ]] && [[ -f "/sys/class/net/$iface/address" ]]; then
            mac=$(cat /sys/class/net/$iface/address)
            echo "MAC_$iface=$mac" >> "$BACKUP_FILE"
        fi
    done
    
    echo -e "${GREEN}[✓] Comprehensive backup saved at $BACKUP_FILE${NC}"
}

# Show what dry-run would do
show_dry_run_changes()
{
    echo -e "${PURPLE}=== DRY-RUN MODE: Changes that would be made ===${NC}"
    
    echo -e "${YELLOW}Cursor & VS Code cleanup:${NC}"
    local cursor_dirs=("$HOME/.cursor" "$HOME/.vscode" "$HOME/.config/Cursor" "$HOME/.config/Code" "$HOME/.config/Cursor/User/globalStorage" "$HOME/.cache/Cursor" "$HOME/.cache/Code")
    for dir in "${cursor_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            echo -e "  ${RED}Would remove:${NC} $dir"
        else
            echo -e "  ${GREEN}Not found:${NC} $dir"
        fi
    done
    
    echo -e "\n${YELLOW}System fingerprint changes:${NC}"
    echo -e "  ${RED}Would regenerate:${NC} /etc/machine-id"
    echo -e "  ${RED}Would regenerate:${NC} /var/lib/dbus/machine-id"
    echo -e "  ${RED}Would change hostname to:${NC} $(generate_random_hostname)"
    
    echo -e "\n${YELLOW}MAC address changes:${NC}"
    ip link show | awk -F: '$1 ~ /^[0-9]+$/ {print $2}' | tr -d ' ' | while read -r iface; do
        if [[ "$iface" != "lo" ]] && [[ -f "/sys/class/net/$iface/address" ]]; then
            current_mac=$(cat /sys/class/net/$iface/address)
            echo -e "  ${RED}Would randomize MAC for $iface:${NC} $current_mac → [random]"
        fi
    done
    
    echo -e "\n${YELLOW}History cleanup:${NC}"
    [[ -f "$HOME/.bash_history" ]] && echo -e "  ${RED}Would clear:${NC} ~/.bash_history"
    [[ -f "$HOME/.zsh_history" ]] && echo -e "  ${RED}Would clear:${NC} ~/.zsh_history"
    
    echo -e "\n${YELLOW}Browser data cleanup:${NC}"
    local browser_dirs=("$HOME/.mozilla/firefox" "$HOME/.cache/mozilla/firefox" "$HOME/.config/google-chrome/Default" "$HOME/.config/chromium/Default")
    for dir in "${browser_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            echo -e "  ${RED}Would remove:${NC} $dir"
        fi
    done
    
    echo -e "${PURPLE}===========================================${NC}"
}

# Restore originals (enhanced)
restore_originals()
{
    if [[ ! -f "$BACKUP_FILE" ]]; then
        echo -e "${RED}[!] No backup found at $BACKUP_FILE. Nothing to undo.${NC}"
        exit 1
    fi

    if [[ "$DRY_RUN" == true ]]; then
        echo -e "${PURPLE}[DRY-RUN] Would restore from backup: $BACKUP_FILE${NC}"
        echo -e "${PURPLE}Backup contents:${NC}"
        cat "$BACKUP_FILE"
        return 0
    fi

    echo -e "${GREEN}[+] Restoring original values from backup...${NC}"
    source "$BACKUP_FILE"

    # Restore hostname
    if [[ -n "$HOSTNAME" ]]; then
        if [[ $EUID -eq 0 ]]; then
            hostnamectl set-hostname "$HOSTNAME"
        else
            sudo hostnamectl set-hostname "$HOSTNAME"
        fi
        echo -e "${YELLOW}[*] Hostname restored: $HOSTNAME${NC}"
    fi
    
    # Restore /etc/hostname if it was backed up
    if [[ -n "$ETC_HOSTNAME" ]]; then
        if [[ $EUID -eq 0 ]]; then
            echo "$ETC_HOSTNAME" > /etc/hostname
        else
            echo "$ETC_HOSTNAME" | sudo tee /etc/hostname >/dev/null
        fi
        echo -e "${YELLOW}[*] /etc/hostname restored${NC}"
    fi

    # Restore machine-id
    if [[ -n "$MACHINE_ID" ]]; then
        if [[ $EUID -eq 0 ]]; then
            echo "$MACHINE_ID" > /etc/machine-id
        else
            echo "$MACHINE_ID" | sudo tee /etc/machine-id >/dev/null
        fi
        echo -e "${YELLOW}[*] Machine ID restored${NC}"
    fi
    
    # Restore D-Bus machine ID
    if [[ -n "$DBUS_MACHINE_ID" ]]; then
        if [[ $EUID -eq 0 ]]; then
            echo "$DBUS_MACHINE_ID" > /var/lib/dbus/machine-id
        else
            echo "$DBUS_MACHINE_ID" | sudo tee /var/lib/dbus/machine-id >/dev/null
        fi
        echo -e "${YELLOW}[*] D-Bus machine ID restored${NC}"
    fi

    # Restore MACs
    grep "MAC_" "$BACKUP_FILE" | while IFS='=' read -r key value; do
        iface="${key#MAC_}"
        if ip link show "$iface" >/dev/null 2>&1; then
            echo -e "${YELLOW}[*] Restoring MAC for $iface → $value${NC}"
            if [[ $EUID -eq 0 ]]; then
                ip link set "$iface" down
                macchanger -m "$value" "$iface" 2>/dev/null || echo -e "${RED}[!] Failed to restore MAC for $iface${NC}"
                ip link set "$iface" up
            else
                sudo ip link set "$iface" down
                sudo macchanger -m "$value" "$iface" 2>/dev/null || echo -e "${RED}[!] Failed to restore MAC for $iface${NC}"
                sudo ip link set "$iface" up
            fi
        fi
    done

    echo -e "${GREEN}[✓] Restoration complete${NC}"
}

# Clean Cursor & related configs
clean_cursor()
{
    if [[ "$DRY_RUN" == true ]]; then
        echo -e "${PURPLE}[DRY-RUN] Would clean Cursor configurations${NC}"
        return 0
    fi
    
    echo -e "${GREEN}[+] Cleaning Cursor configurations...${NC}"
    rm -rf "$HOME/.cursor" "$HOME/.vscode" \
           "$HOME/.config/Cursor" "$HOME/.config/Code" \
           "$HOME/.config/Cursor/User/globalStorage" \
           "$HOME/.cache/Cursor" "$HOME/.cache/Code"
    echo -e "${GREEN}[✓] Cursor configs deleted${NC}"
}

# Reset fingerprints
reset_fingerprints()
{
    if [[ "$DRY_RUN" == true ]]; then
        echo -e "${PURPLE}[DRY-RUN] Would regenerate machine-id and D-Bus IDs${NC}"
        return 0
    fi
    
    echo -e "${GREEN}[+] Regenerating machine-id...${NC}"
    if [[ $EUID -eq 0 ]]; then
        rm -f /etc/machine-id
        dbus-uuidgen --ensure=/etc/machine-id
        rm -f /var/lib/dbus/machine-id
        dbus-uuidgen --ensure
    else
        sudo rm -f /etc/machine-id
        sudo dbus-uuidgen --ensure=/etc/machine-id
        sudo rm -f /var/lib/dbus/machine-id
        sudo dbus-uuidgen --ensure
    fi
    echo -e "${GREEN}[✓] Machine-id regenerated${NC}"
}

# Randomize MAC address
randomize_mac()
{
    if [[ "$DRY_RUN" == true ]]; then
        echo -e "${PURPLE}[DRY-RUN] Would randomize MAC addresses for all interfaces${NC}"
        return 0
    fi
    
    echo -e "${GREEN}[+] Randomizing MAC address...${NC}"
    if ! command -v macchanger >/dev/null 2>&1; then
        echo -e "${RED}[!] macchanger not installed. Installing...${NC}"
        if [[ $EUID -eq 0 ]]; then
            apt-get update && apt-get install -y macchanger
        else
            sudo apt-get update && sudo apt-get install -y macchanger
        fi
    fi

    for iface in $(ip link show | awk -F: '$1 ~ /^[0-9]+$/ {print $2}' | tr -d ' '); do
        if [[ "$iface" != "lo" ]]; then
            echo -e "${YELLOW}[*] Changing MAC for interface: $iface${NC}"
            if [[ $EUID -eq 0 ]]; then
                ip link set "$iface" down
                macchanger -r "$iface"
                ip link set "$iface" up
            else
                sudo ip link set "$iface" down
                sudo macchanger -r "$iface"
                sudo ip link set "$iface" up
            fi
        fi
    done
    echo -e "${GREEN}[✓] MAC addresses randomized${NC}"
}

# Randomize hostname
randomize_hostname()
{
    if [[ "$DRY_RUN" == true ]]; then
        local new_hostname=$(generate_random_hostname)
        echo -e "${PURPLE}[DRY-RUN] Would change hostname to: $new_hostname${NC}"
        return 0
    fi
    
    echo -e "${GREEN}[+] Changing hostname...${NC}"
    new_hostname=$(generate_random_hostname)
    echo -e "${YELLOW}[*] New hostname: $new_hostname${NC}"
    if [[ $EUID -eq 0 ]]; then
        hostnamectl set-hostname "$new_hostname"
    else
        sudo hostnamectl set-hostname "$new_hostname"
    fi
    echo -e "${GREEN}[✓] Hostname changed${NC}"
}

# Clear histories
clear_histories()
{
    if [[ "$DRY_RUN" == true ]]; then
        echo -e "${PURPLE}[DRY-RUN] Would clear shell and browser histories${NC}"
        return 0
    fi
    
    echo -e "${GREEN}[+] Clearing histories...${NC}"
    rm -f "$HOME/.bash_history" "$HOME/.zsh_history"
    history -c 2>/dev/null
    echo -e "${GREEN}[✓] Shell history cleared${NC}"
    rm -rf "$HOME/.mozilla/firefox/"*"/sessionstore"* \
           "$HOME/.cache/mozilla/firefox/"* \
           "$HOME/.config/google-chrome/Default" \
           "$HOME/.config/chromium/Default"
    echo -e "${GREEN}[✓] Browser data cleared${NC}"
}

# Show usage
show_usage()
{
    echo -e "${BLUE}Usage: $0 [OPTIONS]${NC}"
    echo -e "${YELLOW}Options:${NC}"
    echo -e "  ${GREEN}--dry-run${NC}     Show what changes would be made without executing them"
    echo -e "  ${GREEN}--help${NC}        Show this help message"
    echo -e "  ${GREEN}undo${NC}          Restore original system state from backup"
    echo
    echo -e "${YELLOW}Examples:${NC}"
    echo -e "  $0                 # Run interactive mode"
    echo -e "  $0 --dry-run       # Preview changes without making them"
    echo -e "  $0 undo            # Restore from backup"
}

# ================== Main ==================

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --help)
            show_usage
            exit 0
            ;;
        undo)
            check_privileges
            restore_originals
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            show_usage
            exit 1
            ;;
    esac
done

# Main execution
echo -e "${RED}==============================================${NC}"
echo -e "${RED}   Cursor & Fingerprint Reset Utility         ${NC}"
echo -e "${RED}      Enhanced with Dry-run & Safety          ${NC}"
echo -e "${RED}==============================================${NC}"

if [[ "$DRY_RUN" == true ]]; then
    echo -e "${PURPLE}>>> RUNNING IN DRY-RUN MODE <<<${NC}"
    echo -e "${PURPLE}No actual changes will be made${NC}"
    echo
fi

check_privileges

show_fingerprints

if [[ "$DRY_RUN" == true ]]; then
    show_dry_run_changes
    exit 0
fi

echo -e "${BLUE}Do you want to delete Cursor configs? (y/n)${NC}"
read -r delcursor
if [[ "$delcursor" == "y" ]]; then
    clean_cursor
fi

echo -e "${BLUE}Do you want to reset system fingerprints? (y/n)${NC}"
read -r doreset
if [[ "$doreset" == "y" ]]; then
    backup_originals
    reset_fingerprints
    randomize_mac
    randomize_hostname
    clear_histories
fi

echo -e "${BLUE}=== New Fingerprints ===${NC}"
show_fingerprints
echo -e "${GREEN}[✓] Reset complete. Restart recommended.${NC}"
echo -e "${YELLOW}To undo changes later, run:${NC} $0 undo"
echo -e "${YELLOW}To preview changes first, run:${NC} $0 --dry-run"
