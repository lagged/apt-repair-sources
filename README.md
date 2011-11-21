## apt-repair-sources

Find broken packages in your sources.list (or sources.list.d/*).

### Setup

 1. best install REE
 2. `gem install trollop`
 3. clone this repo

### USAGE

Display broken entries on your system:

    ./apt-repair-sources.rb --dry-run

Fix broken entries:

    ./apt-repair-sources.rb --fix-it-for-me


### TODO

 * Step 1: display what's broken (**DONE**)
 * Step 2: fix it (**DONE**)
 * Step 3: autocorrect entries (e.g. distro moves from a mirror to archive, to old-releases)

