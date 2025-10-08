# Linux Identity Reset Tool

A comprehensive bash script for Linux systems that resets system fingerprints, cleans application traces, and provides complete system identity randomization with full backup/restore capabilities.

## 🚀 Features

- **Complete System Identity Reset**: Changes machine ID, hostname, and MAC addresses
- **Application Cleanup**: Removes Cursor/VS Code configurations and traces
- **Safety First**: Comprehensive backup system with one-command restore
- **Dual-Boot Safe**: Smart MAC randomization options that won't affect Windows
- **Dry-Run Mode**: Preview all changes before execution
- **Root Privilege Management**: Smart detection and handling of sudo requirements
- **Browser Data Cleanup**: Clears Firefox, Chrome, and other browser traces
- **History Cleaning**: Removes shell command histories
- **Network Identity**: Multiple MAC randomization options (temporary/permanent)

## 📋 Prerequisites

- Linux system (tested on Kali Linux)
- `sudo` privileges for system-level changes
- `macchanger` (automatically installed if missing for permanent MAC changes)
- `systemd` (for hostname management)

## 🔧 Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/lancedesk/linux-identity-reset-tool.git
   cd linux-identity-reset-tool
   ```

2. **Make the script executable:**
   ```bash
   chmod +x reset_machine.sh
   ```

## 🎯 Usage

### Basic Commands

```bash
# Preview changes without making them (RECOMMENDED FIRST)
./reset_machine.sh --dry-run

# Interactive mode with confirmations
./reset_machine.sh

# Run with root privileges for full system changes
sudo ./reset_machine.sh

# Restore original system state
./reset_machine.sh undo

# Show help
./reset_machine.sh --help
```

### Example Workflow

1. **First, see what would change:**
   ```bash
   ./reset_machine.sh --dry-run
   ```

2. **Run the reset:**
   ```bash
   sudo ./reset_machine.sh
   ```

3. **If needed, restore everything:**
   ```bash
   sudo ./reset_machine.sh undo
   ```

## ⚠️ IMPORTANT: Dual-Boot Systems

### Critical Information for Dual-Boot Users

If you have a **dual-boot system with Windows and Linux**, please read this carefully:

#### The MAC Address Problem

**MAC address changes affect BOTH operating systems** because they modify the physical network adapter at the hardware level. This can cause serious issues in Windows:

- **High CPU usage** from "Service Host" processes
- **Network configuration loops** as Windows tries to reconfigure the "new" adapter
- **Excessive fan noise** due to CPU load
- **Network connectivity problems**
- **Windows Update failures** and service disruptions

#### Recommended Solutions for Dual-Boot

When the script asks about MAC randomization, you have **3 options**:

1. **Skip MAC randomization (RECOMMENDED for dual-boot)**
   - Changes only Linux-specific identifiers
   - Windows remains completely unaffected
   - Safest option for dual-boot systems

2. **Temporary MAC changes**
   - MAC changes only during Linux session
   - Automatically reverts to hardware MAC on reboot
   - Windows will see the original MAC
   - Safe for dual-boot

3. **Permanent MAC changes**
   - Changes persist across reboots
   - **WILL affect Windows** - may cause high CPU and network issues
   - Only use if you understand the consequences

#### If Windows Is Already Affected

If you already ran the script and Windows is experiencing high CPU usage:

**Option A: Restore in Linux**
```bash
sudo ./reset_machine.sh undo
```

**Option B: Fix in Windows**
1. Open Device Manager (Win + X → Device Manager)
2. Expand "Network adapters"
3. Right-click your adapter → Properties
4. Go to "Advanced" tab
5. Find "Network Address" or "Locally Administered Address"
6. Select "Not Present" or delete the value
7. Click OK and reboot

**Option C: Restore hardware MAC in Linux**
```bash
# Replace eth0 with your interface name (check with: ip link show)
sudo macchanger -p eth0
sudo reboot
```

### What Changes Are Safe for Dual-Boot?

✅ **Safe changes (Linux-only):**
- Machine ID (`/etc/machine-id`)
- D-Bus machine ID
- Hostname changes
- Cursor/VS Code cleanup
- Browser data cleanup
- Shell history cleanup

⚠️ **Affects both systems:**
- Permanent MAC address changes

## 📊 What Gets Changed

### System Identifiers
- `/etc/machine-id` - System machine identifier
- `/var/lib/dbus/machine-id` - D-Bus machine identifier  
- `hostname` and `/etc/hostname` - System hostname
- `/etc/hosts` - Updated to prevent "unable to resolve host" errors
- MAC addresses (optional - see dual-boot warnings)

### Application Data
- `~/.cursor` - Cursor editor configurations
- `~/.vscode` - VS Code configurations
- `~/.config/Cursor` - Cursor app data
- `~/.config/Code` - VS Code app data
- Browser caches and profiles
- Shell command histories

### Generated Changes
- **New hostname**: Random format like `host-a1b2c3d4`
- **New MAC addresses**: Optional - temporary or permanent
- **New machine IDs**: Fresh system identifiers
- **Clean histories**: Cleared bash/zsh command histories

## 🔒 Safety Features

### Comprehensive Backup
The script creates a detailed backup file (`~/.fingerprint_reset_backup`) containing:
- Original hostname and `/etc/hostname`
- Original `/etc/hosts` entry for hostname resolution
- Original machine ID and D-Bus machine ID
- MAC addresses for all network interfaces
- Timestamp and system information

### Privilege Checking
- Detects if running as root or with sudo access
- Provides clear error messages for insufficient privileges
- Suggests using `--dry-run` for testing without privileges

### Dry-Run Mode
- Shows exactly what files would be deleted
- Previews all system changes before execution
- Safe testing without making any modifications

### MAC Randomization Options
- **Skip**: No MAC changes (safest for dual-boot)
- **Temporary**: Changes revert on reboot
- **Permanent**: Persistent changes (dual-boot warning displayed)

## 📖 Command Line Options

| Option | Description |
|--------|-------------|
| `--dry-run` | Preview changes without executing them |
| `--help` | Display usage information |
| `undo` | Restore system from backup |
| _(no args)_ | Run in interactive mode |

## 🎨 Sample Output

### Before Reset
```
=== Current System Fingerprints ===
Machine ID: fff172744a6245cda94e6dd013bf4753
Hostname: old-hostname
MAC Addresses:
  14:58:d0:03:3f:4a
  10:4a:7d:bc:51:ec
```

### After Reset
```
=== New Fingerprints ===
Machine ID: 75bf9b225da2448bed95504168cc2a8b
Hostname: host-c44e08l0
MAC Addresses:
  26:19:c8:3c:65:02  (temporary - reverts on reboot)
  de:61:87:b9:20:e7  (temporary - reverts on reboot)
```

## 💡 Best Practices

### For Dual-Boot Systems
1. **Always run `--dry-run` first** to see what will change
2. **Choose "Skip" for MAC randomization** when prompted
3. **Keep a backup** of important configuration files
4. **Test on a non-critical system** first if possible

### For Single-Boot Linux Systems
1. Run `--dry-run` to preview changes
2. Use permanent MAC changes if needed
3. Reboot after reset for full effect
4. Keep the backup file safe for undo operations

### General Recommendations
- **Backup important data** before running the script
- **Run during a maintenance window** if possible
- **Have physical access** to the machine in case of network issues
- **Document your original settings** for reference

## ⚠️ Important Notes

### Post-Reset Actions
- **Reboot recommended** after running the script
- Some changes may require a fresh terminal session
- Network connections may need to be re-established
- **On dual-boot**: Test both operating systems after changes

### Backup File Location
- **User mode**: `$HOME/.fingerprint_reset_backup`
- **Root mode**: `/root/.fingerprint_reset_backup`
- **Each reset overwrites** the previous backup

### Network Interfaces
- Only non-loopback interfaces are modified
- Interface names are auto-detected (`eth0`, `wlan0`, etc.)
- Original MAC addresses are backed up for restoration
- Temporary MACs automatically revert on reboot

## 🛡️ Use Cases

- **Privacy Enhancement**: Change system fingerprints for privacy
- **Development Testing**: Test software behavior with different system IDs  
- **Virtualization**: Reset VM fingerprints after cloning
- **Security Research**: Legitimate penetration testing scenarios
- **System Administration**: Clean slate after system deployment
- **Dual-Boot Privacy**: Separate identities per OS (skip MAC changes)

## 🔧 Troubleshooting

### Common Issues

**"Sudo privileges required"**
- Run with `sudo ./reset_machine.sh` 
- Or use `--dry-run` to preview without privileges

**"Unable to resolve host" error after hostname change**
- This is now automatically fixed by the script
- `/etc/hosts` is updated automatically
- If you see this, you may be using an old version

**"No backup found"**
- Backup is only created when running fingerprint reset
- Each reset overwrites the previous backup

**"macchanger not found"**
- Script automatically installs it for permanent MAC changes
- Manual install: `sudo apt-get install macchanger`
- Not needed for temporary MAC changes

**High CPU in Windows after running script**
- You used permanent MAC changes on a dual-boot system
- See "If Windows Is Already Affected" section above
- Run `./reset_machine.sh undo` or restore in Windows Device Manager

**Temporary MAC changes not working**
- Ensure you have `ip` command available (part of `iproute2`)
- Check network interface names with `ip link show`
- Some interfaces may require driver-specific commands

### Recovery
If something goes wrong, you can always restore:
```bash
sudo ./reset_machine.sh undo
```

## 🔄 Version History

### Latest Version
- ✅ Fixed `/etc/hosts` update to prevent hostname resolution errors
- ✅ Added dual-boot safe MAC randomization options
- ✅ Added temporary MAC changes (session-only)
- ✅ Enhanced backup to include `/etc/hosts` entries
- ✅ Improved restore functionality for dual-boot systems
- ✅ Added comprehensive dual-boot warnings and guidance

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## ⚠️ Disclaimer

This tool is intended for legitimate system administration, privacy enhancement, and security research purposes. Users are responsible for ensuring their use complies with applicable laws and organizational policies. The authors are not responsible for any misuse of this software.

**Dual-Boot Warning**: MAC address changes affect all operating systems on the same hardware. Always understand the implications before making permanent changes.

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/lancedesk/linux-identity-reset-tool/issues)
- **Discussions**: [GitHub Discussions](https://github.com/lancedesk/linux-identity-reset-tool/discussions)

## 🌟 Acknowledgments

- Built for Linux system administrators and privacy-conscious users
- Tested primarily on Kali Linux
- Compatible with most systemd-based distributions
- Community feedback helped improve dual-boot safety

---

**⭐ If this tool helped you, please consider starring the repository!**

**🔔 For dual-boot users**: Always choose "Skip" or "Temporary" MAC randomization to avoid issues!
