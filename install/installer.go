package install

type Installer struct {
	Location    string
	UserHomeDir string
	CmdRunner   CommandRunner
	Config      Config
	Terminal    terminal
}

func NewInstaller(location, userHomeDir string, cmdRunner CommandRunner, config Config, terminal terminal) *Installer {
	return &Installer{
		Location:    location,
		UserHomeDir: userHomeDir,
		CmdRunner:   cmdRunner,
		Config:      config,
		Terminal:    terminal,
	}
}
