#!/usr/bin/env bash
# Pop!OS Post-Install Script

# Setting global var
HOSTNAME="Jarvis"

# Setting auxiliar list
# Debloating Pop!OS inutilities
removing_list=(
    gnome-accessibility-themes
    gnome-contacts
    gnome-calculator
    gnome-font-viewer
    gnome-weather
    gnome-terminal
    xbrlapi
    brltty
    simple-scan
    totem-*
    *libreoffice*
    *firefox*
    geary
    gedit
    pop-shop
)

utilitaries_app=(
    deborphan
    rng-tools5
    numlockx
    zram-config
    build-essential
    nasm
    cpufreqd
    intel-media-va-driver-non-free
    clang
    cargo
    tldr
    nix-bin
    folder-color
    gnome-sushi
    keepassxc
    virtualbox
    virtualbox-guest-additions-iso
    virtualbox-guest-utils
    podman
    preload
    irqbalance
    scrcpy
    systemd-oomd
    libwebkit2gtk-4.0-dev
    build-essential
    curl
    wget
    file
    libssl-dev 
    libgtk-3-dev 
    libayatana-appindicator3-dev
    librsvg2-dev
)

# Setting auxiliar functions
add_flatpak_to_autostart() {
    # Pega o ID do aplicativo como argumento
    local app_id="$1"

    # Verifica se o ID do aplicativo foi fornecido
    if [[ -z "${app_id}" ]]; then
        print_red "Error: No application ID provided."
        return
    fi

    # Verifica se o aplicativo existe no Flathub
    if ! flatpak info "${app_id}" >/dev/null 2>&1; then
        print_red "Error: The application ${app_id} does not exist on Flathub."
        return
    fi

    # Verifica se o diretório de inicialização automática existe, se não, cria
    if [[ ! -d ~/.config/autostart ]]; then
        print_red "The autostart directory does not exist. Creating it now."
        mkdir -p ~/.config/autostart
    fi

    # Verifica se o aplicativo já foi adicionado à inicialização automática
    if [[ -f ~/.config/autostart/"${app_id}".desktop ]]; then
        print_red "Error: The application ${app_id} has already been added to autostart."
        return
    fi

    # Obtém as informações do aplicativo
    local app_info=$(flatpak info --show-metadata "${app_id}")
    local app_name=$(echo "${app_info}" | grep -oP '(?<=name=).*')
    local app_comment=$(echo "${app_info}" | grep -oP '(?<=comment=).*')

    # Cria um arquivo .desktop para o aplicativo no diretório de inicialização automática
    cat > ~/.config/autostart/"${app_id}".desktop <<EOF
[Desktop Entry]
Type=Application
Exec=flatpak run "${app_id}"
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name[en_US]=${app_name}
Name=${app_name}
Comment[en_US]=${app_comment}
Comment=${app_comment}
EOF

    print_green "The Flatpak application ${app_id} has been added to start automatically!"
}

print_green() {
    local text="$1"
    echo -e "\033[0;32m${text}\033[0m"
}

print_red() {
    local text="$1"
    echo -e "\033[0;31m${text}\033[0m"
}

# First update

print_green "[Update Certificates]"

sudo update-ca-certificates

flatpak remote-add --if-not-exists --no-gpg-verify flathub https://flathub.org/repo/flathub.flatpakrepo

sudo apt update && sudo apt upgrade -y && sudo apt dist-upgrade -y && sudo flatpak update && sudo apt autoremove -y && sudo apt autoclean -y

# Setting the hostname
print_green "[Setting the hostname to ${HOSTNAME}]"
hostnamectl set-hostname "${HOSTNAME}"

# Configure the firewall
print_green "[Setting the firewall]"
sudo ufw enable

# Configure mirror speed
print_green "[Setting Mirrors from Brazil]"
sudo sed -i 's|http://us.|http://br.|' /etc/apt/sources.list.d/system.sources
sudo locale-gen pt_BR.utf8
sudo update-locale LANG=pt_BR.utf8

# Configure new repository
print_green "[Adding new Repositories]"
sudo dpkg --add-architecture i386
sudo add-apt-repository multiverse -y
sudo add-apt-repository ppa:oibaf/graphics-drivers -y
sudo apt update

# Install some utilitaries
cd ~/.local/share/fonts && curl -fLO curl -fsSL https://raw.githubusercontent.com/ronniedroid/getnf/master/install.sh | bash

tee -a ~/.bashrc <<-EOF
. "$HOME/.asdf/asdf.sh"
. "$HOME/.asdf/completions/asdf.bash"
EOF

source ~/.bashrc

if [[ -f /var/lib/dpkg/lock-frontend ]]; then
  sudo rm /var/lib/dpkg/lock-frontend
fi

if [[ -f /var/lib/dpkg/lock ]]; then
  sudo rm /var/lib/dpkg/lock
fi

if [[ -f /var/lib/apt/lists/lock ]]; then
  sudo rm /var/lib/apt/lists/lock
fi

if [[ -f /var/cache/apt/archives/lock ]]; then
  sudo rm /var/cache/apt/archives/lock
fi

print_green "Install the package: ${package}"
sudo apt install "${utilitaries_app[@]}" -y --install-recommends --fix-broken;
dpkg --configure -a;

print_green "[Run Debloating]"
while true; do
    ORPHANS=$(sudo deborphan --guess-data)
    if [ -z "$ORPHANS" ]; then
        print_red "Não há mais pacotes órfãos para remover."
        break
    else
        print_green "Removendo pacotes órfãos..."
        $ORPHANS | xargs sudo apt-get -y remove --purge
    
    fi
done

flatpak remove --unused
print_green "Removing the bloat: ${package}..."
sudo apt purge "${removing_list[@]}" -y

# Enable some services
sudo systemctl enable preload
sudo systemctl enable upower
sudo systemctl enable rngd
sudo systemctl enable cpufreqd
sudo systemctl enable thermald
sudo systemctl enable zram-config.service
sudo systemctl enable irqbalance.service
sudo systemctl enable systemd-oomd.service

# Replace the uninstall apps with flatpak apps
print_green "[Install some flatpak apps]"

flatpak install flathub org.gabmus.gfeeds -y
flatpak install flathub com.github.marhkb.Pods -y
flatpak install flathub com.tomjwatson.Emote -y
flatpak install flathub fr.free.Homebank -y
flatpak install flathub com.anydesk.Anydesk -y
flatpak install flathub md.obsidian.Obsidian -y
flatpak install flathub org.mozilla.Thunderbird -y
flatpak install flathub io.freetubeapp.FreeTube -y
flatpak install flathub com.pikatorrent.PikaTorrent -y
flatpak install flathub com.wps.Office -y
flatpak install flathub in.srev.guiscrcpy -y
flatpak install flathub com.discordapp.Discord -y
flatpak install flathub io.github.trigg.discover_overlay -y
flatpak install flathub com.microsoft.Edge -y
flatpak install flathub com.google.Chrome -y

add_flatpak_to_autostart io.github.trigg.discover_overlay

# Optimizing linux
print_green "[Configure Zen Kernel]"
curl -s 'https://liquorix.net/install-liquorix.sh' | sudo bash

print_green "[Configure the swap to use agressive ram first]"
sudo tee -a /etc/sysctl.d/99-sysctl.conf <<-EOF
vm.swappiness=1
vm.vfs_cache_pressure=50
EOF

sudo tee -a /etc/sysctl.d/99-sysctl.conf <<-EOF
vm.dirty_background_bytes=16777216
vm.dirty_bytes=50331648
EOF

print_green "[Configure agressive oomd to use cgroups]"
sudo tee -a /etc/systemd/oomd.config <<-EOF
[OOM]
SwapUsedLimit=95%
MemoryPressureLimit=70%
EOF

print_green "[Configure agressive Upower]"
sudo tee -a /etc/Upower/Upower.conf <<-EOF
PercentageLow=10
PercentageCritical=3
PercentageAction=2
CriticalPowerAction=HybridSleep"
EOF

print_green "[Improving Internet Screen]"
sudo tee -a /etc/sysctl.conf <<-EOF
net.core.netdev_max_backlog=16384
net.core.somaxconn=8192
net.ipv4.tcp_fastopen=3
libahci.ignore_sss=1
EOF

print_green "[Configure journalctl]"
sudo tee -a /etc/systemd/journald.conf <<-EOF
SystemMaxUse=100M
SystemMaxFiles=5 # manter no máximo 5 arquivos
MaxFileSec=1month # deletar logs velhos depois de 1 mês
EOF

if lspci | grep -i "VGA compatible controller: Intel" > /dev/null; then
print_green "Intel i915 driver found."
sudo tee -a /etc/modprobe.d/i915.conf <<-EOF
options i915 modeset=0
options i915 enable_fbc=1
options i915 fastboot=1
options i915 enable_guc=2
EOF
fi

print_green "[Configure Gnome Settings]"
gsettings set org.gnome.SessionManager logout-prompt false
gsettings set org.gnome.desktop.interface enable-animations false
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 900
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type hibernate
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-timeout
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type hibernate
gsettings set org.gnome.settings-daemon.plugins.power power-button-action hibernate
gsettings set org.gnome.desktop.lockdown disable-lock-screen true
gsettings set org.gnome.settings-daemon.plugins.xsettings overrides "[{'Gdk/WindowScalingFactor', <1>}]"
gsettings set org.gnome.desktop.interface scaling-factor 1
gsettings set org.gnome.desktop.interface text-scaling-factor 1

print_green "[Configure personal Directories]"
mkdir -p "$HOME/Documentos/💻 Projetos"
mkdir -p "$HOME/Documentos/⌨️ Fanfics"
mkdir -p "$HOME/💽 bin"
mkdir -p "$HOME/Imagens/📸 Wallpapers"

print_green "All steps completed. Rebooting now.";
sudo systemctl --now daemon-reload;
sudo systemctl --now daemon reexec;
sudo reboot;
