package install

type Packages struct {
	DNF     []string
	Flatpak []string
}

type Config struct {
	Packages Packages
}
