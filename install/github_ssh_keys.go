package install

import (
	"encoding/json"
	"fmt"
	"os"
)

type bwItems struct {
	Items []bwItem
}

type bwItem struct {
	Name  string `json:"name"`
	Notes string `json:"notes"`
}

func (i *Installer) PullSSHKeys(creds BWCreds) error {
	fmt.Println("Unlocking Bitwarden CLI...")
	output, err := i.CmdRunner.RunCommandWithOutput("bw", "unlock", creds.Password, "--raw")
	if err != nil {
		return err
	}

	os.Setenv("BW_SESSION", string(output))

	output, err = i.CmdRunner.RunCommandWithOutput("bw", "list", "items", "--search", "gitub_rsa")
	if err != nil {
		return err
	}

	bwItems := bwItems{Items: []bwItem{}}
	err = json.Unmarshal([]byte(output), &bwItems.Items)
	if err != nil {
		return fmt.Errorf("failed to parse Bitwarden items: %w", err)
	}

	for _, item := range bwItems.Items {
		switch item.Name {
		case "github_rsa":
			err = os.WriteFile(fmt.Sprintf("%s/.ssh/github_rsa", i.UserHomeDir), []byte(item.Notes), 0600)
		case "github_rsa.pub":
			err = os.WriteFile(fmt.Sprintf("%s/.ssh/github_rsa.pub", i.UserHomeDir), []byte(item.Notes), 0600)
		}
	}

	// Start SSH agent and add keys
	fmt.Println("Starting SSH agent...")
	err = i.CmdRunner.RunCommand("ssh-agent", "-s")
	if err != nil {
		return fmt.Errorf("failed to start ssh-agent: %w", err)
	}

	fmt.Println("Adding SSH keys to agent...")
	err = i.CmdRunner.RunCommand("ssh-add", fmt.Sprintf("%s/.ssh/github_rsa", i.UserHomeDir))
	if err != nil {
		return fmt.Errorf("failed to add github_rsa to ssh-agent: %w", err)
	}

	err = i.CmdRunner.RunCommand("ssh-add", fmt.Sprintf("%s/.ssh/hashi", i.UserHomeDir))
	if err != nil {
		return fmt.Errorf("failed to add hashi key to ssh-agent: %w", err)
	}

	fmt.Println("Added SSH keys to the ssh-agent")

	return nil
}
