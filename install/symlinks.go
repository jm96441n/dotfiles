package install

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"
)

func SetupConfigSymlinks(config Config, location string, userHomeDir string) error {
	for src, dest := range config.Symlinks {
		srcPath := location + src
		destPath := userHomeDir + dest
		err := makeDirectoriesForSymlinks(destPath)
		if err != nil {
			return fmt.Errorf("failed to create directories for symlink %s: %w", destPath, err)
		}

		// Remove existing file/symlink if it exists
		if _, err := os.Lstat(destPath); err == nil {
			err = os.Remove(destPath)
			if err != nil {
				return fmt.Errorf("failed to remove existing file at %s: %w", destPath, err)
			}
		}

		err = os.Symlink(srcPath, destPath)
		if err != nil {
			return fmt.Errorf("failed to create symlink from %s to %s: %w", srcPath, destPath, err)
		}
	}
	return nil
}

func makeDirectoriesForSymlinks(path string) error {
	parts := strings.Split(path, "/")
	dir := filepath.Join(parts[:len(parts)-1]...)
	err := os.MkdirAll(dir, 0755)
	if err != nil {
		return fmt.Errorf("failed to create directory for k9s skins: %w", err)
	}

	return nil
}
