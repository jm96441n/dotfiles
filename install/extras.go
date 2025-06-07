package install

import "fmt"

func RunScripts(cfg Config, location string) error {
	for _, script := range cfg.Extras.Scripts {
		scriptPath := location + script
		out, err := runCommandWithOutput(scriptPath)
		if err != nil {
			return err
		}
		fmt.Printf(out)
	}
	return nil
}
