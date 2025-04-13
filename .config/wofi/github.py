#!/usr/bin/env python

import os
import subprocess
import sys

import requests

BASE_URL = "https://github.com"
API_BASE_URL = "https://api.github.com/search/repositories?"


def main():
    token = os.getenv("GITHUB_ACCESS_TOKEN", None)
    headers = {
        "Accept": "application/vnd.github+json",
        "Authorization": f"Bearer {token}",
        "X-GitHub-Api-Version": "2022-11-28",
    }

    # Check if we're being called by wofi or handling a selection
    if len(sys.argv) > 1 and sys.argv[1] == "--dmenu":
        # We're being called by wofi, generate the repo list
        term = os.getenv("WOFI_SEARCH", "")
        repos = []
        for owner_param in ["user:jm96441n", "org:hashicorp"]:
            r = requests.get(
                API_BASE_URL,
                params={"q": f"{term} in:name {owner_param}"},
                headers=headers,
            ).json()
            repos.extend([resp["full_name"] for resp in r["items"]])

        repo_list = "\n".join(repos)
        print(repo_list)
    elif len(sys.argv) > 1 and "github.py" not in sys.argv[1]:
        # We're handling a selection, open the repo
        subprocess.check_call(
            ["xdg-open", f"{BASE_URL}/{sys.argv[1]}"], stdout=subprocess.DEVNULL
        )
    else:
        # Run in dmenu mode if no arguments provided
        process = subprocess.Popen(
            ["wofi", "--dmenu", "--prompt", "GitHub:"],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            text=True,
        )

        # Generate the repo list
        repos = []
        for owner_param in ["user:jm96441n", "org:hashicorp"]:
            r = requests.get(
                API_BASE_URL,
                params={"q": f"in:name {owner_param}"},
                headers=headers,
            ).json()
            repos.extend([resp["full_name"] for resp in r["items"]])

        repo_list = "\n".join(repos)
        selected_repo, _ = process.communicate(input=repo_list)

        if selected_repo.strip():
            subprocess.check_call(
                ["xdg-open", f"{BASE_URL}/{selected_repo.strip()}"],
                stdout=subprocess.DEVNULL,
            )


if __name__ == "__main__":
    main()
