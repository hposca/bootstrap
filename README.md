# Intro

Script created to bootstrap my machine when I upgrade to a new distro. (Debian flavour)

It installs all necessary software and configuration using pure bash.

# Running

```
./bootstrap.sh
```

It will ask for your super user password at the beginning.

# Testing

For basic testing, do the following steps:

1. `vagrant plugin install vagrant-cachier`
1. `vagrant up`
1. `vagrant ssh`
1. `cd /vagrant`
1. `./bootstrap.sh`
