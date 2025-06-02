package install

import (
	"fmt"
	"os"

	"github.com/go-git/go-git/v5"
)

var symlinks = map[string]string{
	"/.config/zsh/.zshrc":                    "/.zshrc",
	"/.config/tmux/.tmux.conf":               "/.tmux.conf",
	"/.config/tmux/.tmux.conf.local":         "/.tmux.conf.local",
	"/.config/tmux/.tmux-cht-command":        "/.tmux-cht-command",
	"/.config/tmux/.tmux-cht-languages":      "/.tmux-cht-languages",
	"/.config/mise/.default-gems":            "/.default-gems",
	"/.config/mise/.default_npm_packages":    "/.default-npm-packages",
	"/.config/mise/.default-python-packages": "/.default-python-packages",
	"/.config/mise/.default-cargo-crates":    "/.default-cargo-crates",
	"/.config/mise/.default-go-packages":     "/.default-go-packages",
	"/.config/mise/mise.toml":                "/.config/mise/config.toml",
	"/.config/nvim":                          "/.config/nnvim",
	"/.config/wofi":                          "/.config/wofi",
	"/.config/waybar":                        "/.config/waybar",
	"/.config/kanshi":                        "/.config/kanshi",
	"/.config/mako":                          "/.config/mako",
	"/.config/sway":                          "/.config/sway",
	"/.config/ranger":                        "/.config/ranger",
	"/.config/bat":                           "/.config/bat",
	"/.config/kitty":                         "/.config/kitty",
	"/.config/k9s/skin.yml":                  "/.config/k9s/skins/everforest-dark.yaml",
	"/.config/k9s/config.yml":                "/.config/k9s/config.yaml",
	"/.config/k9s/views.yml":                 "/.config/k9s/views.yaml",
	"/.config/ghostty/config":                "/.config/ghostty/config",
	"/git/.gitconfig":                        "/.gitconfig",
	"/git/.githelpers":                       "/.githelpers",
}

func SetupConfigSymlinks(userHomeDir string) error {
	err := cloneDotfilesRepo(userHomeDir)
	if err != nil {
		return fmt.Errorf("failed to clone dotfiles repository: %w", err)
	}

	err = makeDirectoriesForSymlinks(userHomeDir)
	if err != nil {
		return fmt.Errorf("failed to create directories for symlinks: %w", err)
	}

	err = createSymlinks(userHomeDir)
	if err != nil {
		return fmt.Errorf("failed to create symlinks: %w", err)
	}

	return nil
}

func cloneDotfilesRepo(userHomeDir string) error {
	_, err := git.PlainClone(userHomeDir+"/.dotfiles", false, &git.CloneOptions{
		URL:      "github.com/jm96441n/dotfiles",
		Progress: os.Stdout,
	})
	if err != nil {
		return err
	}

	return nil
}

func makeDirectoriesForSymlinks(userHomeDir string) error {
	err := os.MkdirAll(userHomeDir+"/.config/k9s/skins", 0755)
	if err != nil {
		return fmt.Errorf("failed to create directory for k9s skins: %w", err)
	}

	err = os.MkdirAll(userHomeDir+"/.config/ghostty", 0755)
	if err != nil {
		return fmt.Errorf("failed to create directory for ghostty: %w", err)
	}

	err = os.MkdirAll(userHomeDir+"/.config/mise", 0755)
	if err != nil {
		return fmt.Errorf("failed to create directory for mise: %w", err)
	}

	return nil
}

func createSymlinks(userHomeDir string) error {
	for src, dest := range symlinks {
		srcPath := userHomeDir + "/.dotfiles" + src
		destPath := userHomeDir + dest
		err := os.Symlink(srcPath, destPath)
		if err != nil {
			return fmt.Errorf("failed to create symlink from %s to %s: %w", srcPath, destPath, err)
		}
	}
	return nil
}
