package install

import (
	"fmt"
	"strings"
)

type BWCreds struct {
	ClientSecret string
	ClientID     string
	Password     string
}

type terminal interface {
	ReadPassword(prompt string) (string, error)
	ReadLine() (string, error)
}

func GetBWCreds(terminal terminal) (BWCreds, error) {
	fmt.Printf("Enter Bitwarden Client ID: ")
	clientID, err := terminal.ReadLine()
	if err != nil {
		return BWCreds{}, fmt.Errorf("failed to read client ID: %w", err)
	}

	clientID = strings.TrimSpace(clientID)
	if clientID == "" {
		return BWCreds{}, fmt.Errorf("client ID cannot be empty")
	}

	secret, err := terminal.ReadPassword("Enter Bitwarden Client Secret: ")
	if err != nil {
		return BWCreds{}, fmt.Errorf("failed to read client secret: %w", err)
	}

	secret = strings.TrimSpace(secret)
	if secret == "" {
		return BWCreds{}, fmt.Errorf("client secret cannot be empty")
	}

	password, err := terminal.ReadPassword("Enter Bitwarden Password: ")
	if err != nil {
		return BWCreds{}, fmt.Errorf("failed to read password: %w", err)
	}

	password = strings.TrimSpace(password)
	if password == "" {
		return BWCreds{}, fmt.Errorf("password cannot be empty")
	}

	return BWCreds{
		ClientSecret: secret,
		ClientID:     clientID,
		Password:     password,
	}, nil
}
