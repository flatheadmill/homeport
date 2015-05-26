# Homeport

This is an experiment to create a portable development environment for projects
that will ultimately be hosted on Linux. By working in a Docker container I can
be certain that I'm not programming to the idioms of my workstation's OS, nor
explicitly accomodate those idioms with platform specific code or lowest-common
denominator code.

I'm able to use shell programs and the GNU toolchain where ever I can run Docker.

My base environment has the languages I use for most development; C, Node.js and
`bash`, along with `zsh`, `vim` and `git` for a shell, editor and source
control respectively.

## Home Directories

Home directories are a challenge.

I didn't know if I wanted to share my host machine's home directory or not, but
I did want to be able to edit the files my Dockerized home from my host machine.
So, either mount my host machine's home directory, or else create a working
directory in my host machine's home directory and mount that.

When you share a directory in your home directory as a Docker volume you end
with permissions problems. With `boot2docker` on OS X, the files in your home
directory will have UID 1000. There ways around this, but I want to keep my
setup as out of the box as possible.

Instead of sharing a directory on the host, I've shared the home directory of
the Docker contianer through Samba, or at least that is the plan.

## Building

Sketching out a build because a friend actually tried to use this...

Specify a UNIX user name and a Docker Hub account name.

```
$ ./configure --user alan --account bigeasy
$ docker/env/create
```

Create data volume based home directories.

```
$ docker/env/create
```

Create your home directories by creating
