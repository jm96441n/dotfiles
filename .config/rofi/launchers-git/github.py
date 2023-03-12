#! /usr/bin/env python

import logging
import os
import subprocess
import sys
import time

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
    args = sys.argv[-1]
    if args[0] == "-":
        term = args[1:]
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
    elif "github.py" not in args:
        subprocess.check_call(["xdg-open", f"{BASE_URL}/{args}"], stdout=subprocess.DEVNULL)


if __name__ == "__main__":
    main()
