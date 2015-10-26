# Homeport Diary


## Decisions

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
