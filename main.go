package main

import (
	"fmt"
	"io"
	"log/slog"
	"os"

	"github.com/BurntSushi/toml"
	"github.com/jm96441n/dotfiles/install"
)

func main() {
	// commands:
	// setup -> does the initial installation setup
	// watch -> runs a file watcher to watch for changes to the dnf package list file and installs diffs
	// update -> runs dnf update and installs any new packages
	logger := slog.New(slog.NewTextHandler(os.Stdout, nil))
	bwCreds, err := install.GetBWCredsFromEnv()
	if err != nil {
		logger.Error("Failed to get Bitwarden credentials from environment", "error", err)
		os.Exit(1)
	}

	userHomeDir, err := os.UserHomeDir()
	if err != nil {
		logger.Error("Failed to get user home directory", "error", err)
		os.Exit(1)
	}

	pkgs, err := readPkgFile(userHomeDir)
	if err != nil {
		logger.Error("Failed to read package file", "error", err)
		os.Exit(1)
	}

	err = install.SetupConfigSymlinks(userHomeDir)
	if err != nil {
		logger.Error("Failed to set up symlinks", "error", err)
		os.Exit(1)
	}

	err = install.FedoraPackages(pkgs)
	if err != nil {
		logger.Error("Failed to install Fedora packages", "error", err)
		os.Exit(1)
	}

	err = install.Fonts(userHomeDir)
	if err != nil {
		logger.Error("Failed to install fonts", "error", err)
		os.Exit(1)
	}
}

func readPkgFile(userHomeDir string) (install.PkgFile, error) {
	path := userHomeDir + "/.dotfiles/install/packages.toml"
	f, err := os.Open(path)
	if err != nil {
		return install.PkgFile{}, fmt.Errorf("failed to open package file %s: %w", path, err)
	}

	defer f.Close()

	pkgFileBytes, err := io.ReadAll(f)
	if err != nil {
		return install.PkgFile{}, fmt.Errorf("failed to read package file %s: %w", path, err)
	}

	pkgFile := install.PkgFile{}
	_, err = toml.Decode(string(pkgFileBytes), &pkgFile)
	if err != nil {
		return install.PkgFile{}, fmt.Errorf("failed to decode package file %s: %w", path, err)
	}

	return pkgFile, nil
}
