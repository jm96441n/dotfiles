package install

import (
	"fmt"
	"os"
	"os/exec"
	"strings"

	"github.com/go-git/go-git/v5"
)

type PkgFile struct {
	dnf     []string
	flatpak []string
}

var fontSymlinks = map[string]string{
	"/system/fonts/icomoon-feather.ttf":  "/usr/share/fonts/icomoon-feather.ttf",
	"/system/fonts/icomoon-feather.ttf_": "/usr/share/fonts/icomoon-feather.ttf_",
	"/system/fonts/siji.pcf":             "/usr/share/fonts/siji.pcf",
}

func Fonts(userHomeDir string) error {
	_, err := git.PlainClone(fmt.Sprintf("%s/.nerd-fonts", userHomeDir), false, &git.CloneOptions{
		URL:      "https://github.com/ryanoasis/nerd-fonts",
		Depth:    1,
		Progress: os.Stdout,
	})
	if err != nil {
		return fmt.Errorf("failed to clone nerd-fonts repository: %w", err)
	}

	err = runCommand(userHomeDir + "/.nerd-fonts/install.sh")
	if err != nil {
		return fmt.Errorf("failed to run nerd-fonts install script: %w", err)
	}

	for src, dest := range fontSymlinks {
		srcPath := userHomeDir + "/.dotfiles" + src
		err = os.Symlink(srcPath, dest)
		if err != nil {
			return fmt.Errorf("failed to create symlink from %s to %s: %w", srcPath, dest, err)
		}
	}

	return nil
}

func FedoraPackages(pkgs PkgFile) error {
	err := dnfUpdate()
	if err != nil {
		return fmt.Errorf("failed to update dnf: %w", err)
	}

	err = extraDNFReposSetup()
	if err != nil {
		return fmt.Errorf("failed to set up extra dnf repositories: %w", err)
	}

	err = dnfInstall(pkgs.dnf)
	if err != nil {
		return fmt.Errorf("failed to install dnf packages: %w", err)
	}

	err = flatpakInstall(pkgs.flatpak)
	if err != nil {
		return fmt.Errorf("failed to install flatpak packages: %w", err)
	}

	return nil
}

func dnfUpdate() error {
	err := runCommand("sudo", "dnf", "update", "-y")
	if err != nil {
		return fmt.Errorf("failed to run dnf update: %w", err)
	}
	return nil
}

var extraDNFRepos = []string{
	"dnf -y install dnf-plugins-core",
	"dnf-3 config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo",
	"dnf config-manager addrepo --from-repofile=https://mise.jdx.dev/rpm/mise.repo",
	"dnf copr enable pgdev/ghostty -y",
	"dnf copr enable atim/lazygit -y",
}

func extraDNFReposSetup() error {
	for _, repo := range extraDNFRepos {
		sp := strings.Split(repo, " ")
		err := runCommand("sudo", sp...)
		if err != nil {
			return fmt.Errorf("failed to run extra dnf repo command '%s': %w", repo, err)
		}
	}

	err := setupKubeCtlRepo()
	if err != nil {
		return err
	}

	err = setupRPMFusionRepos()
	if err != nil {
		return fmt.Errorf("failed to set up RPM Fusion repositories: %w", err)
	}

	return nil
}

func setupKubeCtlRepo() error {
	repoContent := `[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.32/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.32/rpm/repodata/repomd.xml.key
`

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
	err = runCommand("sudo", "mv", tmpFile.Name(), "/etc/yum.repos.d/kubernetes.repo")
	if err != nil {
		return fmt.Errorf("failed to move temp file to /etc/yum.repos.d: %w", err)
	}

	return nil
}

var fusionRepos = []string{
	"https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-%s.noarch.rpm",
	"https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-%s.noarch.rpm",
}

func setupRPMFusionRepos() error {
	version, err := getFedoraVersionRpm()
	if err != nil {
		return fmt.Errorf("failed to get Fedora version: %w", err)
	}

	for _, fusionRepo := range fusionRepos {
		err = runCommand("sudo", "dnf", "install", fmt.Sprintf(fusionRepo, version), "-y")
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

func dnfInstall(pkgs []string) error {
	for _, pkg := range pkgs {
		err := runCommand("sudo", "dnf", "install", pkg, "-y")
		if err != nil {
			return fmt.Errorf("failed to install package %s: %w", pkg, err)
		}
	}

	return nil
}

func flatpakInstall(pkgs []string) error {
	for _, pkg := range pkgs {
		err := runCommand("flatpak", "install", "flathub", "-y", pkg)
		if err != nil {
			return fmt.Errorf("failed to install flatpak package %s: %w", pkg, err)
		}
	}

	return nil
}
