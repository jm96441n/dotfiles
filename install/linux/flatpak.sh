flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

function install {
  echo "Installing: ${1}..."
  flatpak install flathub $1 -y
}

install com.getferdi.Ferdi
install com.spotify.Client
install org.signal.Signal
install us.zoom.Zoom
