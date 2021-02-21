# Homeport

## Configure SSH

```
$ homeport config development --alias development.homeport
```

## Rationalizations

Homeport is written in `bash` since most distributions will have `bash`
available when installed to a server or workstation. It would be nice to be able
to run with `ash` or some lowest-common-denominator shell, but in order to have
a form of argument parsing that can mimic docker arguments I need a full GNU
getopts and the `bash` implementation by Aron Griffis works well and works on
`bash` 3.2 so that we can support OS X.
