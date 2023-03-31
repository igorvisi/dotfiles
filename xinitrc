#!/bin/sh

# Using GnuPG Agent as a SSH agent
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent
