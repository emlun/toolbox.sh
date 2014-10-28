#!/bin/bash

umask go-rwx && sudo -E git -C /etc "$@"
