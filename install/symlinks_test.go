package install

import (
	"os"
	"path/filepath"
	"strings"
	"testing"
)

// Helper function to create temporary directory for testing
func createTempTestDir(t *testing.T) string {
	tempDir, err := os.MkdirTemp("", "dotfiles-test-*")
	Ok(t, err, "failed to create temporary directory")

	t.Cleanup(func() {
		// os.RemoveAll(tempDir)
	})

	return tempDir
}

func TestSetupConfigSymlinks(t *testing.T) {
	testCases := map[string]struct {
		symlinks      map[string]string
		setupFiles    func(string) // function to setup additional files in source directory
		expectedFiles []string     // files that should exist after symlinking
	}{
		"single file symlink": {
			symlinks: map[string]string{
				"/.gitconfig": "/.gitconfig",
			},
			expectedFiles: []string{".gitconfig"},
		},
		"multiple file symlinks": {
			symlinks: map[string]string{
				"/.gitconfig": "/.gitconfig",
				"/.vimrc":     "/.vimrc",
			},
			expectedFiles: []string{".gitconfig", ".vimrc"},
		},
		"nested directory symlink": {
			symlinks: map[string]string{
				"/config/nested/app.conf": "/.config/app/app.conf",
			},
			expectedFiles: []string{".config/app/app.conf"},
		},
		"symlink with existing file": {
			symlinks: map[string]string{
				"/.gitconfig": "/.gitconfig",
			},
			setupFiles: func(tempDir string) {
				// Create existing file that should be replaced
				err := os.WriteFile(filepath.Join(tempDir, ".gitconfig"), []byte("existing content"), 0644)
				if err != nil {
					t.Fatalf("failed to create existing file: %v", err)
				}
			},
			expectedFiles: []string{".gitconfig"},
		},
	}

	for name, tc := range testCases {
		t.Run(name, func(t *testing.T) {
			t.Parallel()

			// Create temporary directory for testing
			tempDir := createTempTestDir(t)

			// Get absolute path to testdata symlinks directory
			testdataSymlinksDir, err := filepath.Abs("testdata/symlinks")
			Ok(t, err, "failed to get absolute path to testdata symlinks")

			// Setup additional files if needed
			if tc.setupFiles != nil {
				tc.setupFiles(tempDir)
			}

			// Create installer with test configuration
			config := DotfilesConfig{
				Symlinks: tc.symlinks,
			}
			installer := NewInstaller(testdataSymlinksDir, tempDir, nil, config, nil)

			// Execute the function
			err = installer.SetupConfigSymlinks()
			Ok(t, err, "failed to setup config symlinks")

			// Verify that expected files exist and are symlinks
			for _, expectedFile := range tc.expectedFiles {
				symlinkPath := filepath.Join(tempDir, expectedFile)

				// Check that file exists
				_, err := os.Lstat(symlinkPath)
				Ok(t, err, "expected symlink %s does not exist", symlinkPath)

				// Check that it's actually a symlink
				info, err := os.Lstat(symlinkPath)
				Ok(t, err, "failed to get file info for %s", symlinkPath)
				Assert(t, info.Mode()&os.ModeSymlink != 0, "expected %s to be a symlink", symlinkPath)

				// Check that symlink points to correct target
				target, err := os.Readlink(symlinkPath)
				Ok(t, err, "failed to read symlink target for %s", symlinkPath)

				// Find the source path for this expected file
				var sourcePath string
				for src, dest := range tc.symlinks {
					if dest == "/"+expectedFile {
						sourcePath = src
						break
					}
				}
				expectedTarget := testdataSymlinksDir + sourcePath
				Assert(t, target == expectedTarget, "expected symlink target %s, got %s", expectedTarget, target)
			}
		})
	}
}

func TestSetupConfigSymlinks_ErrorConditions(t *testing.T) {
	testCases := map[string]struct {
		symlinks      map[string]string
		setupError    func(string, string) // function to setup error condition
		expectedError string
	}{
		"source file does not exist": {
			symlinks: map[string]string{
				"/nonexistent.conf": "/.config/nonexistent.conf",
			},
			setupError: func(tempDir, testdataDir string) {
				// No setup needed - the file doesn't exist
			},
			expectedError: "failed to create symlink",
		},
		"cannot create parent directory": {
			symlinks: map[string]string{
				"/.gitconfig": "/readonly/dir/.gitconfig",
			},
			setupError: func(tempDir, testdataDir string) {
				// Create a file where we need a directory, making it impossible to create subdirectories
				readonlyPath := filepath.Join(tempDir, "readonly")
				err := os.WriteFile(readonlyPath, []byte("blocking file"), 0644)
				if err != nil {
					t.Fatalf("failed to create blocking file: %v", err)
				}
			},
			expectedError: "failed to create directories for symlink",
		},
	}

	for name, tc := range testCases {
		t.Run(name, func(t *testing.T) {
			t.Parallel()

			// Create temporary directory for testing
			tempDir := createTempTestDir(t)

			// Get absolute path to testdata symlinks directory
			testdataSymlinksDir, err := filepath.Abs("testdata/symlinks")
			Ok(t, err, "failed to get absolute path to testdata symlinks")

			// Setup error condition if needed
			if tc.setupError != nil {
				tc.setupError(tempDir, testdataSymlinksDir)
			}

			// Create installer with test configuration
			config := DotfilesConfig{
				Symlinks: tc.symlinks,
			}
			installer := NewInstaller(testdataSymlinksDir, tempDir, nil, config, nil)

			// Execute the function and expect an error
			err = installer.SetupConfigSymlinks()
			Assert(t, err != nil, "expected an error but got none")

			// Check that the error message contains the expected substring
			if tc.expectedError != "" {
				Assert(t,
					strings.Contains(err.Error(), tc.expectedError),
					"expected error to contain %q, got: %s", tc.expectedError, err.Error())
			}
		})
	}
}
