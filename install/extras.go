package install

import "fmt"

func (i *Installer) RunScripts() error {
	for _, script := range i.Config.Extras.Scripts {
		scriptPath := i.Location + script
		out, err := i.CmdRunner.RunCommandWithOutput(scriptPath)
		if err != nil {
			return err
		}
		fmt.Printf(out)
	}
	return nil
}
