
[Back to Index](README.md)

# Homebrew Casks at Home

Installing **casks** is **NOT homebrewing**. Instead the beer is delivered from the brewery and just sold under the label of Homebrew. You have to accept the terms given by the brewery. That means in many cases you can't simply install the applications into your users directoy and admin privileges are required. However there are some tricks to circumvent the limitations.

You can take the easy way and install casks with admin privileges into the common global directories. As said above, you don't have full control anyway, so this isn't a bad decision after all. But maybe you don't want to do that. Maybe you keep your programs on an USB stick. Maybe you need to run different versions in parallel. Let's see what we can do.

While *Apps* like **Goolge Chrome.app** or **iTerm.app** are comparingly flexible, *package installers* like **Vagrant.pkg** or **VirtualBox.pkg** are stubborn.

## Install Packages to a Sparse Image

 **VirtualBox.pkg** doesn't give you a choice at all, **Vagrant.pkg** let's you choose the partition, when you ran the interacive install tool. The latter case can be addressed by a sparse image within your home directory, that is mounted as a partion.

Fire up the **Disk Utility**. Create a sparse image of a large upper limit of size, in example 10G. Give it the Name **APPLICATIONS** so that it get's mounted as `/Volumes/APPLICATIONS`. Save it as `~/Homebrew/Applications.sparseimage`. Use the interactive install tool to install to this partition. Doing this with **Vagrant.pkg** the directories `Library` and `opt` are created. You find the binary as `opt/vagrant/bin/vagrant`. Setup an alias to call it simply as `vagrant` or include the directory into `PATH`. To automount the sparse image you open `Preferences > Users & Groups > Current User > Login Items` and add the sparse image.

`homebrew cask` wasn't involved here at all. This approach is fully interacive. So you have to decide either to install packages *by automation* with `homebrew cask` but into the *global direcories* or *manually* into your *home directory*.

## Install Apps into Your Homebrew Directory

### Setup your Caskroom at Home

Visit http://caskroom.io. Get **Cask**.

```
brew install caskroom/cask/brew-cask

```
Prepare your Caskroom. First customize `.bash_profile` with your preferred editor:
```
vim ~/.bash_profile
```
```
export HOMEBREW_CASK_OPTS="--appdir=$HOME/Applications --caskroom=$HOMEBREW_PREFIX/Caskroom"
```
Do:
```
source ~/.bash_profile
```

### Order some Casks

* `brew cask google-chrome iterm2`
* `ls -al ~/Applications`

The applicatins are symlinked into `~/Applications` and occur on your Launchpad.

