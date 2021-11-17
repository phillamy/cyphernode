#!/bin/sh

# Perform unattended key generation
# https://www.gnupg.org/documentation/manuals/gnupg/Unattended-GPG-key-generation.html
gpg --batch --gen-key .gnupgp/key-definition.txt
