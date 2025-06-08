package install

import (
	"fmt"
	"io"
	"os"

	"github.com/goccy/go-yaml"
)

type Config struct {
	Symlinks map[string]string `yaml:"symlinks"`
	Packages Packages          `yaml:"packages"`
	Shell    Shell             `yaml:"shell"`
	Tools    Tools             `yaml:"tools"`
	Extras   Extras            `yaml:"extras"`
}

type Packages struct {
	DNF     *DNF
	Flatpak *[]string
}

type DNF struct {
	Packages  []string `yaml:"packages"`
	ExtraRepo []string `yaml:"extra-repo"`
	Copr      []string `yaml:"copr"`
	Fusion    bool     `yaml:"fusion"`
	Kubectl   *Kubectl `yaml:"kubectl"`
}

type Kubectl struct {
	Version string `yaml:"version"`
}

type Shell struct {
	Zsh Zsh `yaml:"zsh"`
}

type Zsh struct {
	OhMyZsh *OhMyZsh `yaml:"oh-my-zsh"`
}

type OhMyZsh struct {
	Plugins []string `yaml:"plugins"`
}

type Tools struct {
	Mise Mise `yaml:"mise"`
}

type Mise struct {
	Enabled bool `yaml:"enabled"`
}

type Extras struct {
	Scripts []string `yaml:"scripts"`
}

func ReadConfigFile(userHomeDir string) (Config, error) {
	path := userHomeDir + "/.dotfiles/dotfiles.yaml"
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
	err = yaml.Unmarshal(configFileBytes, &configFile)
	if err != nil {
		return Config{}, fmt.Errorf("failed to decode package file %s: %w", path, err)
	}

	return configFile, nil
}
