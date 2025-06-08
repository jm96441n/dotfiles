package install

import (
	"fmt"
	"os"
	"os/exec"
	"strings"

	"github.com/go-git/go-git/v5"
)

// Removed type aliases - using CommandRunner interface instead

func (i *Installer) Fonts() error {
	_, err := git.PlainClone(fmt.Sprintf("%s/.nerd-fonts", i.UserHomeDir), false, &git.CloneOptions{
		URL:      "https://github.com/ryanoasis/nerd-fonts",
		Depth:    1,
		Progress: os.Stdout,
	})
	if err != nil {
		return fmt.Errorf("failed to clone nerd-fonts repository: %w", err)
	}

	err = i.CmdRunner.RunCommand(i.UserHomeDir + "/.nerd-fonts/install.sh")
	if err != nil {
		return fmt.Errorf("failed to run nerd-fonts install script: %w", err)
	}

	return nil
}

func (i *Installer) SetupPackages() error {
	if i.Config.Packages.DNF == nil {
		err := i.dnf()
		if err != nil {
			return fmt.Errorf("failed to install dnf packages: %w", err)
		}

	}

	if i.Config.Packages.Flatpak == nil {
		err := i.flatpakInstall()
		if err != nil {
			return fmt.Errorf("failed to install flatpak packages: %w", err)
		}
	}

	return nil
}

func (i *Installer) dnf() error {
	err := i.dnfUpdate()
	if err != nil {
		return fmt.Errorf("failed to update dnf: %w", err)
	}

	err = i.extraDNFReposSetup()
	if err != nil {
		return fmt.Errorf("failed to set up extra dnf repositories: %w", err)
	}

	err = i.dnfInstall()
	if err != nil {
		return fmt.Errorf("failed to install dnf packages: %w", err)
	}
	return nil
}

func (i *Installer) dnfUpdate() error {
	err := i.CmdRunner.RunCommand("sudo", "dnf", "update", "-y")
	if err != nil {
		return fmt.Errorf("failed to run dnf update: %w", err)
	}
	return nil
}

func (i *Installer) extraDNFReposSetup() error {
	err := i.CmdRunner.RunCommand("sudo", "dnf", "install", "dnf-plugins-core", "-y")
	if err != nil {
		return fmt.Errorf("failed to install dnf-plugins-core: %w", err)
	}

	for _, repo := range i.Config.Packages.DNF.ExtraRepo {
		err := i.CmdRunner.RunCommand("sudo", "dnf", "config-manager", "addrepo", fmt.Sprintf("--from-repofile=%s", repo))
		if err != nil {
			return fmt.Errorf("failed to add extra dnf repo '%s': %w", repo, err)
		}
	}

	for _, copr := range i.Config.Packages.DNF.Copr {
		err := i.CmdRunner.RunCommand("sudo", "dnf", "copr", "enable", copr, "-y")
		if err != nil {
			return fmt.Errorf("failed to enable copr repository '%s': %w", copr, err)
		}
	}

	if i.Config.Packages.DNF.Kubectl != nil {
		err = i.setupKubeCtlRepo()
		if err != nil {
			return err
		}
	}

	if i.Config.Packages.DNF.Fusion {
		err = i.setupRPMFusionRepos()
		if err != nil {
			return fmt.Errorf("failed to set up RPM Fusion repositories: %w", err)
		}
	}

	return nil
}

func (i *Installer) setupKubeCtlRepo() error {
	repoContent := fmt.Sprintf(`[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/%s/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.32/rpm/repodata/repomd.xml.key
`, i.Config.Packages.DNF.Kubectl.Version)

	// Write to temporary file first
	tmpFile, err := os.CreateTemp("", "kubernetes-repo-*.repo")
	if err != nil {
		return fmt.Errorf("failed to create temp file: %w", err)
	}
	defer os.Remove(tmpFile.Name()) // Clean up

	_, err = tmpFile.WriteString(repoContent)
	if err != nil {
		return fmt.Errorf("failed to write to temp file: %w", err)
	}
	tmpFile.Close()

	// Move temp file to final location with sudo
	err = i.CmdRunner.RunCommand("sudo", "mv", tmpFile.Name(), "/etc/yum.repos.d/kubernetes.repo")
	if err != nil {
		return fmt.Errorf("failed to move temp file to /etc/yum.repos.d: %w", err)
	}

	return nil
}

var fusionRepos = []string{
	"https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-%s.noarch.rpm",
	"https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-%s.noarch.rpm",
}

func (i *Installer) setupRPMFusionRepos() error {
	version, err := getFedoraVersionRpm()
	if err != nil {
		return fmt.Errorf("failed to get Fedora version: %w", err)
	}

	for _, fusionRepo := range fusionRepos {
		err = i.CmdRunner.RunCommand("sudo", "dnf", "install", fmt.Sprintf(fusionRepo, version), "-y")
		if err != nil {
			return fmt.Errorf("failed to install RPM Fusion repository: %w", err)
		}
	}

	return nil
}

func getFedoraVersionRpm() (string, error) {
	cmd := exec.Command("rpm", "-E", "%fedora")
	output, err := cmd.Output()
	if err != nil {
		return "", err
	}

	version := strings.TrimSpace(string(output))
	// Check if it's actually a version number (not %fedora unexpanded)
	if version == "%fedora" {
		return "", fmt.Errorf("rpm macro not expanded")
	}

	return version, nil
}

func (i *Installer) dnfInstall() error {
	for _, pkg := range i.Config.Packages.DNF.Packages {
		err := i.CmdRunner.RunCommand("sudo", "dnf", "install", pkg, "-y")
		if err != nil {
			return fmt.Errorf("failed to install package %s: %w", pkg, err)
		}
	}

	return nil
}

func (i *Installer) flatpakInstall() error {
	for _, pkg := range *i.Config.Packages.Flatpak {
		err := i.CmdRunner.RunCommand("flatpak", "install", "flathub", "-y", pkg)
		if err != nil {
			return fmt.Errorf("failed to install flatpak package %s: %w", pkg, err)
		}
	}

	return nil
}
