# Intro

Script created to bootstrap my machine when I upgrade to a new distro. (Debian flavour)

It installs all necessary software and configuration using [Ansible](https://github.com/ansible/ansible).

# Running

```
sudo ./bootstrap.sh
```

# Things to do after bootstrap process

Few things will need manual intervention after the bootstrap process, like:

- Start vim manually, to complete the plugins' installation process
- Run the Dropbox daemon, to configure it:
    `$ ~/.dropbox-dist/dropboxd`

# Testing

For basic testing, do the following steps:

1. `vagrant up`
1. `vagrant ssh`
1. `cd /vagrant`
1. `sudo ./bootstrap.sh`
