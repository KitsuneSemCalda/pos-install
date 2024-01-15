# Pop!_OS Post-Install Script

This is a Bash script for post-installation tasks on Pop!_OS. It automates various configurations, installations, and optimizations to enhance the user experience.

>[!CAUTION]
This is a very personal script, if you want run in your pc probably need modification

## Features

- System updates and certificate refresh.
- Firewall configuration with UFW.
- Mirrors optimization for faster updates.
- Adding new repositories for additional software.
- Installation of essential utilities and packages.
- Flatpak installations for popular applications.
- Configuration of kernel and swap for performance.
- System optimizations for memory and performance.
- GNOME settings customization.
- Pipewire configuration for audio.
- Creation of personal directories.

## Fast Usage

1. Using cURL to execute this script fastly

```bash
curl -s https://raw.githubusercontent.com/KitsuneSemCalda/pos-install/master/install.sh | sudo bash
```

2. Follow the on-screen prompts and instructions.

## Usage

1. Clone the repository or download the script.

```bash
   git clone https://github.com/KitsuneSemCalda/pos-install
```

2. Make the script executable.

```bash
chmod +x install.sh
```

3. Run the script

```bash
./install.sh
```

4. Follow the on-screen prompts and instructions

> [!WARNING]
> This script performs various system configurations and installations.

> [!WARNING]
> Review the script and understand the changes it makes before running it.

> [!WARNING]
> Use it at your own risk, and make sure to have backups before making significant changes to your system.

> [!NOTE]
> Feel free to customize and share this script.
> Contributions and feedback are welcome!

## License

This script is licensed under the [MIT License](https://github.com/KitsuneSemCalda/pos-install/tree/master/LICENSE).
