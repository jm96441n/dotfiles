package install

import (
	"bufio"
	"fmt"
	"os"
)

func ProgrammingLangs(userHomeDir string) error {
	// Install programming languages using mise
	err := mise()
	if err != nil {
		return fmt.Errorf("failed to install programming languages: %w", err)
	}

	// Additional setup for programming languages can be added here
	err = rust(userHomeDir)
	if err != nil {
		return fmt.Errorf("failed to install Rust: %w", err)
	}

	return nil
}

func mise() error {
	err := runCommand("mise", "install")
	if err != nil {
		return err
	}

	return nil
}

func rust(userHomeDir string) error {
	err := runCommand("sh", "-c", "curl", "--proto", "'=https'", "--tlsv1.2", "-sSf", "https://sh.rustup.rs", "|", "sh")
	if err != nil {
		return fmt.Errorf("failed to install Rust: %w", err)
	}

	defaultCratesFile, err := os.Open(userHomeDir + "/.default-cargo-crates")
	if err != nil {
		return fmt.Errorf("failed to open default cargo crates file: %w", err)
	}

	scanner := bufio.NewScanner(defaultCratesFile)
	for scanner.Scan() {
		pkg := scanner.Text()
		err = runCommand("cargo", "install", pkg)
		if err != nil {
			return fmt.Errorf("failed to install cargo crate %s: %w", pkg, err)
		}
	}

	return nil
}
