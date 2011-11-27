## apt-repair-sources

Find broken packages in your sources.list (or sources.list.d/*). This code is [BSD licensed][bsd].

[bsd]: http://www.opensource.org/licenses/bsd-license.php

### Setup

#### GEMS!

    gem install apt-repair-sources

#### From source

 1. `gem install trollop`
 2. clone this repo

### USAGE

Display broken entries on your system:

    apt-repair-sources [--dry-run]

Fix broken entries:

    apt-repair-sources --fix-it-for-me (or -f)

### TODO

 * Step 1: display what's broken (**DONE**)
 * Step 2: fix it (**DONE**)
 * Step 3: autocorrect entries (e.g. distro moves from a mirror to archive, to old-releases) (**DONE**)
 * Step 4: offer a gem (**DONE**)
 * Step 5: add Debian support
