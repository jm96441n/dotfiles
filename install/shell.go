package install

import (
	"fmt"
	"os"
	"os/exec"
	"strings"
)

func SetupShell(config Config, userHomeDir string) error {
	if config.Shell.Type == "zsh" {
		// Install zsh if not already installed
		err := installZsh()
		if err != nil {
			return fmt.Errorf("failed to install zsh: %w", err)
		}

		// Set zsh as the default shell
		err = setDefaultShell(userHomeDir)
		if err != nil {
			return fmt.Errorf("failed to set zsh as default shell: %w", err)
		}

		fmt.Println("Successfully set up zsh as the default shell")
	}

	return nil
}

func installZsh() error {
	// Check if zsh is already installed
	_, err := exec.LookPath("zsh")
	if err == nil {
		fmt.Println("zsh is already installed")
		return nil
	}

	fmt.Println("Installing zsh...")
	err = runCommand("sudo", "dnf", "install", "zsh", "-y")
	if err != nil {
		return fmt.Errorf("failed to install zsh: %w", err)
	}

	return nil
}

func setDefaultShell(userHomeDir string) error {
	// Get the path to zsh
	zshPath, err := exec.LookPath("zsh")
	if err != nil {
		return fmt.Errorf("zsh not found in PATH: %w", err)
	}

	// Get current user
	currentUser := os.Getenv("USER")
	if currentUser == "" {
		return fmt.Errorf("USER environment variable not set")
	}

	// Check if zsh is already the default shell
	currentShell := os.Getenv("SHELL")
	if strings.Contains(currentShell, "zsh") {
		fmt.Println("zsh is already the default shell")
		return nil
	}

	fmt.Printf("Setting zsh as default shell for user %s...\n", currentUser)
	err = runCommand("sudo", "chsh", "-s", zshPath, currentUser)
	if err != nil {
		return fmt.Errorf("failed to change default shell to zsh: %w", err)
	}

	return nil
}
