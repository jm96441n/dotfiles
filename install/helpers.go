package install

import (
	"os"
	"os/exec"
)

func runCommand(name string, args ...string) error {
	// run an os.Exec command with the provided name and arguments
	cmd := exec.Command(name, args...)

	// Connect to stdin/stdout so user can interact with sudo prompt
	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	err := cmd.Run()
	if err != nil {
		return err
	}
	return nil
}

type cmdOutputError struct {
	msg string
}

func (e cmdOutputError) Error() string {
	return e.msg
}

func runCommandWithOutput(name string, args ...string) (string, error) {
	// run an os.Exec command with the provided name and arguments
	cmd := exec.Command(name, args...)

	// Connect to stdin/stdout so user can interact with sudo prompt
	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	output, err := cmd.Output()
	if err != nil {
		msg := "Command failed: " + name + " " + args[0]
		if exitError, ok := err.(*exec.ExitError); ok {
			msg += "\nExit text: " + string(exitError.Stderr)
		}
		return "", cmdOutputError{msg: msg}
	}

	return string(output), nil
}
