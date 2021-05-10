function build_signal() {
  . /etc/os-release
  OS=$NAME
  if [[ $(is-macos) == 0 && $OS == "Fedora" ]]; then
    git clone https://github.com/signalapp/Signal-Desktop.git ~/.gitware/SignalDesktop
    cd Signal-Desktop
    git checkout tags/v1.12.0
    npm install
    npm run dist-prod
    sudo ln -s ~/.gitware/Signal-Desktop/dist/linux-unpacked/signal-desktop /usr/local/bin/signal-desktop
    sudo cp ~/.gitware/Signal-Desktop/images/icon_250.png /usr/local/share/icons/signal.png
    echo "Desktop Entry" >> /usr/local/share/applications/signal.desktop
    echo "Name=Signal Desktop" >> /usr/local/share/applications/signal.desktop
    echo "Comment=Private messaging from your desktop" >> /usr/local/share/applications/signal.desktop
    echo "Exec=signal-desktop" >> /usr/local/share/applications/signal.desktop
    echo "Terminal=false" >> /usr/local/share/applications/signal.desktop
    echo "Type=Application" >> /usr/local/share/applications/signal.desktop
    echo "Icon=signal.png" >> /usr/local/share/applications/signal.desktop
    echo "StartupWMClass=Signal" >> /usr/local/share/applications/signal.desktop
  fi
}

build_signal
