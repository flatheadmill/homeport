# Homeport Diary

Need to find a way to make properties available to installation scripts.

Need to find a way to install extensions. Might want to create a Cellar like
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
