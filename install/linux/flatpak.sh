flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

function install {
  echo "Installing: ${1}..."
  flatpak install flathub $1 -y
}

install org.ferdium.Ferdium
install com.spotify.Client
install org.signal.Signal
install us.zoom.Zoom
install com.bitwarden.desktop
