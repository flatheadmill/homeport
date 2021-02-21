# Homeport

## Installing

Homeport is a single `bash` script. You can install it by downloading it from
GitHub and making it executable.

```
$ curl URL
$ chmod 755 homeport
```

Alternatively, you can extract the script from and existing Homeport image.

```
$ docker run --rm homeport/ubuntu > homeport
$ chmod 755 homeport
```

## Running

Homeport has a `homeport run` command that takes agruments identical to the `run`
command of your `installed` docker. You run a Homeport image by invoking

```
$ homeport [docker options] run [docker run options] <homeport image>
```

When Homeport runs it will add Homeport specific arguments your run command.
Specifically, it will...

 * mount the Homeport home directory volume,
 * mount `~/.ssh` at `/home/homeport/.ssh`,
 * mount `/var/run/docker.sock` at `/var/run/docker.sock`, (TODO maybe optional)
 * publish port 22,
 * run detached,
 * label the container io.homeport=true, (TODO What? Why `io`?),
 * change the entry point to the Homeport sshd start script.

```
$ homeport run --net development --name dev --hostname dev image/ubuntu
```

## Configure SSH

To connect to the Homeport image you create an SSH config file using `homeport
config`. For this to work you need to include the Homeport managed SSH
configuration in your `~/.ssh/config`. Add the following line to your
`~/.ssh/config`.

```
Include ~/.ssh/homeport.config
```

Now you can configure ssh with the `homeport config` command.

```
$ homeport config dev --alias development
$ ssh -A development
```

Now you can use all of the `ssh` features to communicate with your container.
You can `scp` and `rsync` files and browse wiht `sftp`. I find these to be more
performant and easier to work with than the slow file mounting between OS X and
a Linux container.

## Building Homeport

Homeport will emit a Dockerfile for Ubuntu or Apline. You can build a Homeport
image by piping that file from `homeport dockerfile` to `docker build`.

```
$ homeport dockerfile --distro ubuntu | docker build -t homeport/ubuntu -
```

If you want to create your own customized Homeport image start with one of the
emitted `Dockerfiles` and customize it.

## X11

Best I can get so far is this...

https://medium.com/@mreichelt/how-to-show-x11-windows-within-docker-on-mac-50759f4b65cb

Which requires X11 authentication to be off. Would have to spend more time
learning about magic cookies and trying to determine what's wrong with my
netowrk configuration. Do note that address family has to be `inet` and not
`any` for the socket to even spawn in the container when you `ssh -X` or `ssh
-Y`.

## Rationalizations

Homeport is written in `bash` since most distributions will have `bash`
available when installed to a server or workstation. It would be nice to be able
to run with `ash` or some lowest-common-denominator shell, but in order to have
a form of argument parsing that can mimic docker arguments I need a full GNU
getopts and the `bash` implementation by Aron Griffis works well and works on
`bash` 3.2 so that we can support OS X.

## TODO

Probably need an install step to create the home directory and such so that we
don't stomp on something that belongs to the user (but would the home directory
really stomp?)
