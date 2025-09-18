# Linux Identity Reset Tool

A comprehensive bash script for Linux systems that resets system fingerprints, cleans application traces, and provides complete system identity randomization with full backup/restore capabilities.

## 🚀 Features

- **Complete System Identity Reset**: Changes machine ID, hostname, and MAC addresses
- **Application Cleanup**: Removes Cursor/VS Code configurations and traces
- **Safety First**: Comprehensive backup system with one-command restore
- **Dry-Run Mode**: Preview all changes before execution
- **Root Privilege Management**: Smart detection and handling of sudo requirements
- **Browser Data Cleanup**: Clears Firefox, Chrome, and other browser traces
- **History Cleaning**: Removes shell command histories
- **Network Identity**: Randomizes MAC addresses for all network interfaces

## 📋 Prerequisites

- Linux system (tested on Kali Linux)
- `sudo` privileges for system-level changes
- `macchanger` (automatically installed if missing)
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

## 📊 What Gets Changed

### System Identifiers
- `/etc/machine-id` - System machine identifier
- `/var/lib/dbus/machine-id` - D-Bus machine identifier  
- `hostname` and `/etc/hostname` - System hostname
- MAC addresses for all network interfaces

### Application Data
- `~/.cursor` - Cursor editor configurations
- `~/.vscode` - VS Code configurations
- `~/.config/Cursor` - Cursor app data
- `~/.config/Code` - VS Code app data
- Browser caches and profiles
- Shell command histories

### Generated Changes
- **New hostname**: Random format like `host-a1b2c3d4`
- **New MAC addresses**: Completely randomized for all interfaces
- **New machine IDs**: Fresh system identifiers
- **Clean histories**: Cleared bash/zsh command histories

## 🔒 Safety Features

### Comprehensive Backup
The script creates a detailed backup file (`~/.fingerprint_reset_backup`) containing:
- Original hostname and `/etc/hostname`
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
  26:19:c8:3c:65:02
  de:61:87:b9:20:e7
```

## ⚠️ Important Notes

### Post-Reset Actions
- **Reboot recommended** after running the script
- Some changes may require a fresh terminal session
- Network connections may need to be re-established

### Backup File Location
- **User mode**: `$HOME/.fingerprint_reset_backup`
- **Root mode**: `/root/.fingerprint_reset_backup`

### Network Interfaces
- Only non-loopback interfaces are modified
- Interface names are auto-detected (`eth0`, `wlan0`, etc.)
- Original MAC addresses are backed up for restoration

## 🛡️ Use Cases

- **Privacy Enhancement**: Change system fingerprints for privacy
- **Development Testing**: Test software behavior with different system IDs  
- **Virtualization**: Reset VM fingerprints after cloning
- **Security Research**: Legitimate penetration testing scenarios
- **System Administration**: Clean slate after system deployment

## 🔧 Troubleshooting

### Common Issues

**"Sudo privileges required"**
- Run with `sudo ./reset_machine.sh` 
- Or use `--dry-run` to preview without privileges

**"No backup found"**
- Backup is only created when running fingerprint reset
- Each reset overwrites the previous backup

**"macchanger not found"**
- Script automatically installs it via `apt-get`
- Manual install: `sudo apt-get install macchanger`

### Recovery
If something goes wrong, you can always restore:
```bash
sudo ./reset_machine.sh undo
```

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

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/lancedesk/linux-identity-reset-tool/issues)
- **Discussions**: [GitHub Discussions](https://github.com/lancedesk/linux-identity-reset-tool/discussions)

## 🌟 Acknowledgments

- Built for Linux system administrators and privacy-conscious users
- Tested primarily on Kali Linux
- Compatible with most systemd-based distributions

---

**⭐ If this tool helped you, please consider starring the repository!**
