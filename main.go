package main

import (
	"flag"
	"fmt"
	"log/slog"
	"os"

	"github.com/jm96441n/dotfiles/install"
	"golang.org/x/term"
)

func main() {
	if len(os.Args) < 2 {
		fmt.Fprintf(os.Stderr, "Usage: %s <command> [options]\n", os.Args[0])
		fmt.Fprintf(os.Stderr, "Commands:\n")
		fmt.Fprintf(os.Stderr, "  setup   - does the initial installation setup\n")
		fmt.Fprintf(os.Stderr, "  watch   - runs a file watcher to watch for changes to the dnf package list file and installs diffs\n")
		os.Exit(1)
	}

	switch os.Args[1] {
	case "setup":
		setupCommand()
	case "watch":
		watchCommand()
	default:
		fmt.Fprintf(os.Stderr, "Unknown command: %s\n", os.Args[1])
		os.Exit(1)
	}
}

func setupCommand() {
	setupFlags := flag.NewFlagSet("setup", flag.ExitOnError)
	var (
		repoURL            string
		location           string
		configFileLocation string
	)
	setupFlags.StringVar(&repoURL, "repo", "", "URL to the remote repository containing the dotfiles")
	setupFlags.StringVar(&location, "location", "", "Location to clone the dotfiles repository, default is '$HOME/.dotfiles'")
	setupFlags.StringVar(&configFileLocation, "config", "/dotfiles.toml", "Relative path to the config file within your dotfiles repo, default is '/dotfiles.toml'")
	setupFlags.Parse(os.Args[2:])

	logger := slog.New(slog.NewTextHandler(os.Stdout, nil))
	terminal := term.NewTerminal(os.Stdin, "")

	if repoURL == "" {
		logger.Error("Repository URL is required", "error", "You must provide a repository URL using the --repo flag")
		os.Exit(1)
	}

	userHomeDir, err := os.UserHomeDir()
	if err != nil {
		logger.Error("Failed to get user home directory", "error", err)
		os.Exit(1)
	}

	if location == "" {
		location = userHomeDir + "/dotfiles"
	}

	err = install.CloneRepo(repoURL, location)
	if err != nil {
		logger.Error("Failed to clone repository", "error", err)
		os.Exit(1)
	}

	oldState, err := term.MakeRaw(int(os.Stdin.Fd()))
	if err != nil {
		panic(err)
	}
	defer term.Restore(int(os.Stdin.Fd()), oldState)

	bwCreds, err := install.GetBWCreds(terminal)
	if err != nil {
		logger.Error("Failed to get Bitwarden credentials", "error", err)
		os.Exit(1)
	}

	config, err := install.ReadConfigFile(userHomeDir)
	if err != nil {
		logger.Error("Failed to read package file", "error", err)
		os.Exit(1)
	}

	err = install.SetupConfigSymlinks(userHomeDir)
	if err != nil {
		logger.Error("Failed to set up symlinks", "error", err)
		os.Exit(1)
	}

	err = install.FedoraPackages(config)
	if err != nil {
		logger.Error("Failed to install Fedora packages", "error", err)
		os.Exit(1)
	}

	err = install.Fonts(userHomeDir)
	if err != nil {
		logger.Error("Failed to install fonts", "error", err)
		os.Exit(1)
	}

	err = install.PullSSHKeys(bwCreds, userHomeDir)
	if err != nil {
		logger.Error("Failed to pull SSH keys from Bitwarden", "error", err)
		os.Exit(1)
	}

	err = install.SetupOhMyZsh(config, userHomeDir)
	if err != nil {
		logger.Error("Failed to set up shell", "error", err)
		os.Exit(1)
	}

	err = install.RunScripts(config, location)
	if err != nil {
		logger.Error("Failed to run extra scripts", "error", err)
		os.Exit(1)
	}
}

func watchCommand() {
	watchFlags := flag.NewFlagSet("watch", flag.ExitOnError)
	watchFlags.Parse(os.Args[2:])

	fmt.Println("Watch command not yet implemented")
}
