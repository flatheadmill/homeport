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
