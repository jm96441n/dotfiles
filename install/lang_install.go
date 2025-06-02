package install

import "fmt"

func Mise() error {
	err := runCommand("mise", "install")
	if err != nil {
		return fmt.Errorf("failed to run mise install: %w", err)
	}

	return nil
}
