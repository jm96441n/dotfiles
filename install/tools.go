package install

import (
	"fmt"
)

func SetupTools(config Config, userHomeDir string, cmdRunner CommandRunner) error {
	if !config.Tools.Mise.Enabled {
		return nil
	}
	// Install programming languages using mise
	err := setupMise(userHomeDir, cmdRunner)
	if err != nil {
		return fmt.Errorf("failed to set up mise: %w", err)
	}

	return nil
}

func setupMise(userHomeDir string, cmdRunner CommandRunner) error {
	err := cmdRunner.RunCommand("mise", "install")
	if err != nil {
		return err
	}

	return nil
}
