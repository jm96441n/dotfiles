package install

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"github.com/go-git/go-git/v5"
)

func SetupOhMyZsh(config Config, userHomeDir string) error {
	ohMyZshDir := filepath.Join(userHomeDir, ".oh-my-zsh")

	// Check if Oh My Zsh is already installed
	if _, err := os.Stat(ohMyZshDir); err == nil {
		fmt.Println("Oh My Zsh is already installed")
	} else {
		// Install Oh My Zsh
		fmt.Println("Installing Oh My Zsh...")
		err := installOhMyZsh(userHomeDir)
		if err != nil {
			return fmt.Errorf("failed to install Oh My Zsh: %w", err)
		}
	}

	// Install plugins
	for _, plugin := range config.OhMyZsh.Plugins {
		err := installOhMyZshPlugin(plugin, userHomeDir)
		if err != nil {
			return fmt.Errorf("failed to install plugin %s: %w", plugin, err)
		}
	}

	fmt.Println("Successfully set up Oh My Zsh with plugins")
	return nil
}

func installOhMyZsh(userHomeDir string) error {
	// Download and install Oh My Zsh
	installScript := "\"$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\" \"\" --unattended"
	err := runCommand("sh", "-c", installScript)
	if err != nil {
		return fmt.Errorf("failed to install Oh My Zsh: %w", err)
	}

	return nil
}

func installOhMyZshPlugin(plugin string, userHomeDir string) error {
	pluginsDir := filepath.Join(userHomeDir, ".oh-my-zsh", "custom", "plugins")

	pluginParts := strings.Split(plugin, "/")
	pluginName := pluginParts[len(pluginParts)-1]
	pluginDir := filepath.Join(pluginsDir, pluginName)
	if _, err := os.Stat(pluginDir); err == nil {
		fmt.Printf("Plugin %s is already installed\n", plugin)
		return nil
	}

	fmt.Printf("Installing plugin: %s\n", plugin)
	_, err := git.PlainClone(pluginDir, false, &git.CloneOptions{
		URL:      plugin,
		Progress: os.Stdout,
	})
	if err != nil {
		return fmt.Errorf("failed to clone %s: %w", plugin, err)
	}

	return nil
}
