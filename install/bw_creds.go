package install

import (
	"fmt"
	"os"
)

type BWCreds struct {
	ClientSecret string
	ClientID     string
	Password     string
}

type envVarNotSetError struct {
	key string
}

func (e envVarNotSetError) Error() string {
	return fmt.Sprintf("environment variable %s is not set", e.key)
}

func GetBWCredsFromEnv() (BWCreds, error) {
	secret, err := mustGetFromEnv("BITWARDEN_CLIENT_SECRET")
	if err != nil {
		return BWCreds{}, err
	}

	clientID, err := mustGetFromEnv("BITWARDEN_CLIENT_ID")
	if err != nil {
		return BWCreds{}, err
	}

	password, err := mustGetFromEnv("BITWARDEN_PASSWORD")
	if err != nil {
		return BWCreds{}, err
	}
	return BWCreds{
		ClientSecret: secret,
		ClientID:     clientID,
		Password:     password,
	}, nil
}

func mustGetFromEnv(key string) (string, error) {
	strng := os.Getenv(key)
	if strng == "" {
		return "", envVarNotSetError{key: key}
	}
	return strng, nil
}
