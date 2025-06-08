package install

import (
	"os"
	"os/exec"
)

// CommandRunner interface for testability
type CommandRunner interface {
	RunCommand(name string, args ...string) error
	RunCommandWithOutput(name string, args ...string) (string, error)
}

// commandRunner implements CommandRunner for actual execution
type commandRunner struct{}

func NewCommandRunner() CommandRunner {
	return commandRunner{}
}

// RealCommandRunner methods
func (r commandRunner) RunCommand(name string, args ...string) error {
	cmd := exec.Command(name, args...)
	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	return cmd.Run()
}

func (r commandRunner) RunCommandWithOutput(name string, args ...string) (string, error) {
	cmd := exec.Command(name, args...)
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

// Legacy functions for backward compatibility
func RunCommand(name string, args ...string) error {
	runner := commandRunner{}
	return runner.RunCommand(name, args...)
}

type cmdOutputError struct {
	msg string
}

func (e cmdOutputError) Error() string {
	return e.msg
}

func RunCommandWithOutput(name string, args ...string) (string, error) {
	runner := commandRunner{}
	return runner.RunCommandWithOutput(name, args...)
}

// MockCommandRunner implements CommandRunner for testing
type MockCommandRunner struct {
	Commands []MockCommand
	Outputs  map[string]string
	Errors   map[string]error
}

type MockCommand struct {
	Name string
	Args []string
}

// MockCommandRunner methods
func (m *MockCommandRunner) RunCommand(name string, args ...string) error {
	m.Commands = append(m.Commands, MockCommand{Name: name, Args: args})
	key := name + " " + argsToString(args)
	if err, exists := m.Errors[key]; exists {
		return err
	}
	return nil
}

func (m *MockCommandRunner) RunCommandWithOutput(name string, args ...string) (string, error) {
	m.Commands = append(m.Commands, MockCommand{Name: name, Args: args})
	key := name + " " + argsToString(args)
	if err, exists := m.Errors[key]; exists {
		return "", err
	}
	if output, exists := m.Outputs[key]; exists {
		return output, nil
	}
	return "", nil
}

func argsToString(args []string) string {
	result := ""
	for i, arg := range args {
		if i > 0 {
			result += " "
		}
		result += arg
	}
	return result
}
