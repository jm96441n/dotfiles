package install

import (
	"os"

	"github.com/go-git/go-git/v5"
)

func CloneRepo(repoURL, destDir string) error {
	_, err := git.PlainClone(destDir, false, &git.CloneOptions{
		URL:      repoURL,
		Progress: os.Stdout,
	})
	if err != nil {
		return err
	}

	return nil
}
