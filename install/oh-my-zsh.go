package install

import (
	"fmt"
	"os"
	"path/filepath"
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
	installScript := "sh -c \"$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\" \"\" --unattended"
	err := runCommand("sh", "-c", installScript)
	if err != nil {
		return fmt.Errorf("failed to install Oh My Zsh: %w", err)
	}
	
	return nil
}

func installOhMyZshPlugin(plugin string, userHomeDir string) error {
	pluginsDir := filepath.Join(userHomeDir, ".oh-my-zsh", "custom", "plugins")
	
	switch plugin {
	case "zsh-autosuggestions":
		pluginDir := filepath.Join(pluginsDir, "zsh-autosuggestions")
		if _, err := os.Stat(pluginDir); err == nil {
			fmt.Printf("Plugin %s is already installed\n", plugin)
			return nil
		}
		
		fmt.Printf("Installing plugin: %s\n", plugin)
		err := runCommand("git", "clone", "https://github.com/zsh-users/zsh-autosuggestions", pluginDir)
		if err != nil {
			return fmt.Errorf("failed to clone %s: %w", plugin, err)
		}
		
	case "zsh-syntax-highlighting":
		pluginDir := filepath.Join(pluginsDir, "zsh-syntax-highlighting")
		if _, err := os.Stat(pluginDir); err == nil {
			fmt.Printf("Plugin %s is already installed\n", plugin)
			return nil
		}
		
		fmt.Printf("Installing plugin: %s\n", plugin)
		err := runCommand("git", "clone", "https://github.com/zsh-users/zsh-syntax-highlighting.git", pluginDir)
		if err != nil {
			return fmt.Errorf("failed to clone %s: %w", plugin, err)
		}
		
	case "zsh-completions":
		pluginDir := filepath.Join(pluginsDir, "zsh-completions")
		if _, err := os.Stat(pluginDir); err == nil {
			fmt.Printf("Plugin %s is already installed\n", plugin)
			return nil
		}
		
		fmt.Printf("Installing plugin: %s\n", plugin)
		err := runCommand("git", "clone", "https://github.com/zsh-users/zsh-completions", pluginDir)
		if err != nil {
			return fmt.Errorf("failed to clone %s: %w", plugin, err)
		}
		
	default:
		fmt.Printf("Unknown plugin: %s, skipping...\n", plugin)
	}
	
	return nil
}
