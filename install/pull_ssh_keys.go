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

func PullSSHKeys(creds BWCreds, userHomeDir string) error {
	fmt.Println("Unlocking Bitwarden CLI...")
	output, err := runCommandWithOutput("bw", "unlock", creds.Password, "--raw")
	if err != nil {
		return err
	}

	os.Setenv("BW_SESSION", string(output))

	output, err = runCommandWithOutput("bw", "list", "items", "--search", "gitub_rsa")
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
			err = os.WriteFile(fmt.Sprintf("%s/.ssh/github_rsa", userHomeDir), []byte(item.Notes), 0600)
		case "github_rsa.pub":
			err = os.WriteFile(fmt.Sprintf("%s/.ssh/github_rsa.pub", userHomeDir), []byte(item.Notes), 0600)
		}
	}

	return nil
}
