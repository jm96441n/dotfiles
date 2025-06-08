package install

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"github.com/go-git/go-git/v5"
)

func (i *Installer) SetupOhMyZsh() error {
	ohMyZshDir := filepath.Join(i.UserHomeDir, ".oh-my-zsh")

	// Check if Oh My Zsh is already installed
	if _, err := os.Stat(ohMyZshDir); err == nil {
		fmt.Println("Oh My Zsh is already installed")
		return nil
	}
	// Install Oh My Zsh
	fmt.Println("Installing Oh My Zsh...")
	err := installOhMyZsh(i.UserHomeDir, i.CmdRunner)
	if err != nil {
		return fmt.Errorf("failed to install Oh My Zsh: %w", err)
	}

	// Install plugins
	for _, plugin := range i.Config.Shell.Zsh.OhMyZsh.Plugins {
		err := installOhMyZshPlugin(plugin, i.UserHomeDir)
		if err != nil {
			return fmt.Errorf("failed to install plugin %s: %w", plugin, err)
		}
	}

	// Handle .zshrc backup created by Oh My Zsh installation
	err = restoreOriginalZshrc(i.UserHomeDir)
	if err != nil {
		return fmt.Errorf("failed to restore original .zshrc: %w", err)
	}

	fmt.Println("Successfully set up Oh My Zsh with plugins")
	return nil
}

func installOhMyZsh(userHomeDir string, cmdRunner CommandRunner) error {
	// Download and install Oh My Zsh
	installScript := "\"$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\" \"\" --unattended"
	err := cmdRunner.RunCommand("sh", "-c", installScript)
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

func restoreOriginalZshrc(userHomeDir string) error {
	zshrcBackup := filepath.Join(userHomeDir, ".zshrc.pre-oh-my-zsh")
	zshrcPath := filepath.Join(userHomeDir, ".zshrc")

	// Check if the backup file exists
	_, err := os.Stat(zshrcBackup)
	if err == nil {
		fmt.Println("Restoring original .zshrc from backup")

		// Remove the current .zshrc (created by Oh My Zsh)
		err = os.Remove(zshrcPath)
		if err != nil && !os.IsNotExist(err) {
			return fmt.Errorf("failed to remove .zshrc: %w", err)
		}

		// Rename the backup to .zshrc
		err = os.Rename(zshrcBackup, zshrcPath)
		if err != nil {
			return fmt.Errorf("failed to restore .zshrc from backup: %w", err)
		}

		fmt.Println("Successfully restored original .zshrc")
		return nil
	}

	if !os.IsNotExist(err) {
		return fmt.Errorf("failed to check for .zshrc backup: %w", err)
	}
	// If backup doesn't exist, nothing to restore

	return nil
}
