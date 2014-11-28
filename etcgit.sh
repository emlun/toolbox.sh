#!/bin/bash
# Execute git in /etc with umask set to disallow everything for non-owners

umask go-rwx && sudo -E git -C /etc "$@"
