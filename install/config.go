package install

type Packages struct {
	DNF     []string
	Flatpak []string
}

type Config struct {
	Packages Packages
}
package install

type DotfilesConfig struct {
	Packages Packages  `toml:"packages"`
	Shell    Shell     `toml:"shell"`
	OhMyZsh  OhMyZsh   `toml:"oh-my-zsh"`
	Extras   Extras    `toml:"extras"`
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
