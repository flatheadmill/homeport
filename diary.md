# Homeport Diary


## Decisions

 * We don't version formulas in the image, because we don't version `apt-get`,
 we can never garuntee that we're going to build the exact same image in the
 exact same order.
 * Naming is `@image` and `home@` or `home@user`.
 * You're fighting a war inside your head against multi-tenancy, and
 multi-tenancy is losing. You're not going to have a user specifed UNIX user
 name, the user name is always `homeport`.
 * All images reside in the `homeport` namespace.
 * There are no meaningful arguments to the `homeport` program, only to the
 sub-programs.
 * Simple means of passing parameters to installation scripts. Anything more and
 you're going to have to write an installation script that has your special
 properties.

## Concerns

 * Need to find a way to install extensions. Might want to create a Cellar like
 `brew`. Need to adopt search paths.

## Naming

Some new decisions about namespacing and naming. Subject to change, but for now,
I'd like to move from erring on complexity to erring on simplicity.

Docker implies single user machines. Multi-tenancy has been on the decline for
the last twenty years. Linux at first, then virtualization. Homeport images are
not going to be multi-tenant images. Users of multi-tenant systems are not going
to be able to share the use of Docker. This is just not how it is going to be
used. It will be used either by a developer on their personal workstation, or
deployed to an server dedicated to a particular application. They are not going
to be logging into the VAX at the computer lab, really where is anyone going to
encounter a multi-tenant Linux? Their Hostgator account?

Thus, no more host user name and guest user name. Also, let's use the `homeport`
account as the namespace. Utilities provided by `homeport` are going to not have
an underscore in their name, but all other images will be. We can find homeport
images by looking in `homeport`.

What about hosting at Docker Hub? If I want to publish an image, how do I
distinquish that image on my local machine? We can use the tag for that, because
we only ever use `latest` and `foundation`, we could have a tag like
`by_bigeasy`, or similar. There is currently no way to distinquish namespaces
between `quay.io` and Docker Hub, so we're in collision territory anyway.

Looks as though there is going to be no versioning then. The tag is used for
versioning. I suppose we could split the tag, `bigeasy.8.1.0` and
`bigeasy.latest`, so that could come back.

Nice that Docker overbuilt the namespacing. Pity that NPM underbuilt it.

## The `homeport` User

It's not as though this is going to be an identifiable home. No one is going to
be addressed by their homeport user account. We're going to run out of
identifiers, or rather, I'd rather use the secondary identifier to name the home
directory conatiner for freezing and thawing, instead of naming the user inside
the containers. This means that home directories and images are going to be more
or less interchangable, at least until we're supporting other distributions
besides Ubuntu.

It is the sort of thing that might ordinarily take me a long time to let go of,
because it is tradition, it is functionality, and because I'm annoyned to be
addresses as `vagrant`, `ec2-user`, or `ubuntu`. but this is a losing battle and
a pointless battle. I'm not going to be using email except through IMAP, so I'm
not going to be `homeport@prettyrobots.com`. I'm not on a machine that has other
users, so they're not going to send mail email, or `talk` to me.


## Rebuilding

We don't version formulas in the image, because we don't version `apt-get`, we
can never garuntee that we're going to build the exact same image in the exact
same order. If you change a formula significantly, rearrange it's arguments,
then append it, we're going to run that command, but we're going to run it as a
replacement for the first invocation. Thus, you're not supposed to run a command
over and over again, say, changing a configuration with the formula, running
some more formulas, then changing it back. When we flatten, we run every formula
once, and with one set of arguments, thus a formula is supposed to make things a
certain way.

Thus, you wouldn't create a formula for `sed` and use it to fix files.

```
$ homeport append example formula/replace:/etc/passwd,mysql,sql
$ homeport append example formula/replace:/etc/group,mysql,sql
```

A formula is supposed to alter the system in a certain way, it declares the way
a particular aspect of the system shall be, and each invocation of the formula
is supposed to perform its changes in their entirety.

## Saving Home Directories

It is not possible to simply commit them, because there is home is a volume, and
volumes are not kept in the image, they are in a directory on the host machine.

Could freeze by creating an image, but I already want to solve the problem of
file transfers between containers, so I'm going to work on that problem. You'll
be able to rsync to a remove container. Thus, no freezing of home directories.
If you want something to be shared through Docker Hub, put it in an image. If
you want to update the home directory from a docker hub, maybe you can make an
image of your own that mounts the volume, or something

## Homeport Teleport

It occurs to me now that it makes more sense to have teleporting put you in a
shell in Homeport, that you ought to be able to bootstrap yourself into
homeport, and that their should be a homeport formula. Thus, in order to create
this property, I probably want to work from within a homeport to build homeport,
etc, that it never needs to be installed anywhere, is is always an image.

Or more simply, no leading anything and the word `formula` means that you use a
default formula, otherwise say `./formula` to indicate that you want to use a
formula off the local machine. We don't have to change as much as quickly if we
do it this way, there ought to be a way to build a basic machine this way.

Additionally, there can be some way to pull formulae out of images.

```
homeport append formula/apt-get zsh vim rsync git
homeport append docker://bigeasy/homeport_extra:tag/formulae/node 0.12.7
homeport append https://www.prettyrobots.com/formulae/node.tar.gz 0.12.7
homeport append ./formula/tidy
```

And so on.

## Simplier Home Directories

The best part is that your homeport home directory is your home directory, I
mean, wouldn't that be nice? Or would it. Imagine an option to, instead of using
a volume, to use your home directory. Now you can run docker specifying the
files in your home directory as mounted volumes. What if you're on a CoreOS
machine, do you really want to litter core's home directory? Yeah, why not?

Yeah, but really? Okay. Well, what about using a lot of NFS? You could serve the
home directories from Docker, then if you wanted to create a volume from within
your docker instance, you could mount the home directories somewhere on the
host, translate the path.

Okay, these are not simpiler. This is an unsimple thing.
