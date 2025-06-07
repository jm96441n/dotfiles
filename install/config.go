package install

import (
	"fmt"
	"io"
	"os"

	"github.com/BurntSushi/toml"
)

type Config struct {
	Packages Packages `toml:"packages"`
	Shell    Shell    `toml:"shell"`
	OhMyZsh  OhMyZsh  `toml:"oh-my-zsh"`
	Extras   Extras   `toml:"extras"`
}

type Packages struct {
	DNF     []string
	Flatpak []string
}

type Shell struct {
	Type string `toml:"type"`
}

type OhMyZsh struct {
	Plugins []string `toml:"plugins"`
}

type Extras struct {
	Scripts []string `toml:"scripts"`
}

func ReadConfigFile(userHomeDir string) (Config, error) {
	path := userHomeDir + "/.dotfiles/dotfiles.toml"
	f, err := os.Open(path)
	if err != nil {
		return Config{}, fmt.Errorf("failed to open package file %s: %w", path, err)
	}

	defer f.Close()

	configFileBytes, err := io.ReadAll(f)
	if err != nil {
		return Config{}, fmt.Errorf("failed to read package file %s: %w", path, err)
	}

	configFile := Config{}
	_, err = toml.Decode(string(configFileBytes), &configFile)
	if err != nil {
		return Config{}, fmt.Errorf("failed to decode package file %s: %w", path, err)
	}

	return configFile, nil
}
