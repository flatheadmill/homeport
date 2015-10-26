[![Stories in Ready](https://badge.waffle.io/bigeasy/homeport.png?label=ready&title=Ready)](https://waffle.io/bigeasy/homeport)
# Homeport

Homeport is a Dockerized Linux development environment. It's basically a Linux
shell account you can hack in where ever you're able to run Docker.

Homeport creates a home directory for you in a data volume. You can then build
different Homeport images and run a shell. From your shell you can edit your
home directory.

Currently, I'm able to build different images with different build tools, I'm
able to tag these images so I can visit my home directory armed with Node.js
with one image, or armed with Ruby with aother.

It's nifty way to do dependency management.

Future directions:

 * Exposing the home directory to the host operating system via Samba, so you
 can use the tools on your workstation.
 * Syncing the home directory using BitTorrent Sync.
 * Way to migrate home directories from one version of Ubuntu to the next. Some
 [notes on that score](http://stackoverflow.com/questions/23137544/how-to-map-volume-paths-using-dockers-volumes-from), or else I could import and export using `tar`.

If you have suggestions, please place them in [milestone
discussion](https://github.com/bigeasy/homeport/issues/1).

## Details

Homeport is always the latest Ubuntu.

## Installation

To come:

 * Installation via Homebrew.
 * Installation via `curl | bash`.

For now, you can checkout the source code from the GitHub repository, and then
place a link to `./homeport` somewhere in your `PATH`.


## Creating an Image

Create an image with `homeport create`. Add packages with `homeport append`.

```console
$ homeport create
$ homeport append vim rsync zsh
$ homeport append git
```

The `homeport create` command will create a default homeport Ubuntu image that
has a user account that has the same name as the user account used to create
image on the host machine.

The packages will be installed using `apt-get`. New images will be created.

```console
$ whoami
alan
$ docker images | grep '\(REPOSITORY\|homeport\)'
REPOSITORY                    TAG          IMAGE ID       CREATED       VIRTUAL SIZE
homeport_alan_alan_default    latest       4268a86a11d5   9 hours ago   459.8 MB
homeport_alan_alan_default    foundation   8d6e8de11c1c   9 hours ago   248.3 MB
```

In the above list, you can see that homeport has created a two images (I'm
getting rid of one of them.) One is the base image that was generated by
`homeport create`. The other is the latest image for generated by repeated
called to `homeport append`. The latest image is the one that is run when you
type `homeport run`.

## Running Your Image

For now, you need to first create a home direcotry. This will create a home
directory with your public SSH key obtained from `ssh-agent`.

```
$ homeport home
```

Now you can start the homeport SSH server and connect to it via ssh.

```
$ homeport run
$ homeport ssh
```

You should drop into `bash`.

## Adding Packages

Packages are added with `homeport append` as described in **Creating an Image**.
Packages are installed using `apt-get`.

After you add new packages you're going to need to restart your SSH server.

```
$ homeport append ruby
$ homeport rm
```

## Formulas: Alternative Package Managers and Custom Builds

Often times you need to install packages using an alternative package manager
such as `npm`, `gem`, or `pip`. To install using an alternative package manager
you create a formula.

To install using Python's `pip`, you first create a formula in a file named `pip`.

```
#!/bin/bash

pip install "$@"
```

You can now invoke the formula from `homeport append`. To distinguish the
formula from a package you **must** specify a path to the formula that includes
a slash (`/`).

```
$ homeport append ./pip:awscli
```

Now instead of telling `apt-get` to install a module, `homeport append` will
copy your `./pip` formula into the image, then run it with a single argument of
`awscli`.

You can specify multiple arguments to the formula by delimiting them with comma.

```
$ homeport append ./pip:boto,pygments
```

Note that there is no way to pass a comma into a formula. If you need to pass in
complicated arguments, you should simply write a one off formula instead.

## Hacking

Notes to self, installing Vagrant to install Ubuntu.

```
$ brew tap phinze/homebrew-cask && brew install brew-cask
$ brew cask install vagrant
$ vagrant plugin install vagrant-vbox-snapshot
$ vagrant box add trusty https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box
$ mkdir ~/homeport && cd ~/homeport
$ vagrant init trusty
```

You now need to add `config.ssh.forward_agent = true` to the `Vagrantfile`.

```
$ vagrant up
$ vagrant ssh
```

Install Docker on Ubuntu.

```
$ sudo apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
$ echo deb https://apt.dockerproject.org/repo ubuntu-trusty main | sudo tee /etc/apt/sources.list.d/docker.list
$ sudo apt-get update
$ sudo apt-get purge lxc-docker*
$ sudo apt-get install docker
$ sudo usermod -aG docker vagrant
$ docker run hello-world
```
