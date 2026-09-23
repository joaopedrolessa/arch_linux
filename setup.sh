#!/usr/bin/env bash
set -Eeuo pipefail
trap 'echo; echo "[ERRO] Falhou na linha $LINENO. Corrija o erro antes de executar novamente."; exit 1' ERR

if [[ $EUID -eq 0 ]]; then
  echo "Execute como usuario normal (ex.: jaypi), NAO como root."
  exit 1
fi
[[ -f /etc/arch-release ]] || { echo "Este script foi feito para Arch Linux."; exit 1; }
command -v sudo >/dev/null || { echo "sudo nao esta instalado/configurado."; exit 1; }

echo "=== Atualizando Arch ==="
sudo pacman -Syu --noconfirm

echo "=== Instalando Hyprland e ambiente ==="
sudo pacman -S --needed --noconfirm   base-devel git curl wget nano vim networkmanager linux-headers mesa   hyprland kitty waybar wofi xdg-desktop-portal-hyprland xdg-desktop-portal-gtk   qt5-wayland qt6-wayland polkit-kde-agent   pipewire pipewire-audio pipewire-alsa pipewire-pulse wireplumber pavucontrol   mako wl-clipboard cliphist grim slurp brightnessctl playerctl fastfetch   unzip zip p7zip firefox thunar thunar-archive-plugin gvfs   noto-fonts noto-fonts-emoji ttf-dejavu man-db man-pages

sudo systemctl enable NetworkManager

mkdir -p "$HOME/.config/hypr"
if [[ ! -f "$HOME/.config/hypr/hyprland.conf" ]]; then
cat > "$HOME/.config/hypr/hyprland.conf" <<'EOF'
monitor=,preferred,auto,1

input {
    kb_layout = us
    kb_variant = intl
}

$mod = SUPER
bind = $mod, RETURN, exec, kitty
bind = $mod, Q, killactive
bind = $mod, M, exit
bind = $mod, D, exec, wofi --show drun
bind = $mod, E, exec, thunar
bind = $mod, F, exec, firefox

exec-once = waybar
exec-once = mako
exec-once = /usr/lib/polkit-kde-authentication-agent-1
exec-once = wl-paste --type text --watch cliphist store
exec-once = wl-paste --type image --watch cliphist store
EOF
fi

if systemd-detect-virt | grep -qi vmware; then
  echo "VMware detectado."
  sudo pacman -S --needed --noconfirm open-vm-tools gtkmm3
  sudo systemctl enable vmtoolsd.service
fi

echo
echo "Nenhum driver proprietario NVIDIA foi instalado."
echo "No PC fisico manteremos Nouveau como padrao."
echo
echo "Teste primeiro:"
echo "  Hyprland"
echo
echo "Se funcionar, instale o ML4W Stable pelo instalador oficial:"
echo "  bash <(curl -s https://ml4w.com/os/stable)"
echo
echo "ML4W nao e iniciado automaticamente porque seu instalador e interativo e altera dotfiles."
