[Back to Index](README.md)

# Homebrew at Home
Run **[Homebrew](http://brew.sh)** completely inside your home directory — as it's name promises — without ringing the admin. 

## About

The standard setup of **Homebrew** requires superuser privileges and installs homebrew globally. One reason is, that *some programs* expect to be installed into `/usr/local`. The **Homebrew team** wants to prevent the users to run into troubles with this few programs by setting up this strict limitation for the default setup.

However, all programs that **I personally** tested within the last two years, didn't suffer from this limitation. They also worked on a user defined path. You configure it by setting the `HOMEBREW_PREFIX`.

## Any requirements?

* Xcode - From the **App Store** and installed as an admin. (Didn't I promise without ringing the admin? I am sure she already did this if she is worth her money.)

## What does it do?

* Editing your `.profile` by creation or appending.
* Setting up `HOMEBREW_PREFIX`, `HOMEBREW_CACHE` and `HOMEBREW_TEMP`.
* Setting up the `PATH` to include the bin directories.
* Cloning the **Homebrew** sources directly from the master branch on **GitHub**.
* Creating a temporary directory on the very same partition. Important!

## 12 lines of code altogether!

First customize `.bash_profile` with your preferred editor: 

```
vim ~/.bash_profile
```

```
export HOMEBREW_PREFIX="$HOME/Library/Homebrew"
export HOMEBREW_TEMP="$HOMEBREW_PREFIX/Temp"
export HOMEBREW_CACHE="$HOME/Library/Caches/Homebrew"
export PATH="$HOMEBREW_PREFIX/bin:$PATH"
export PATH="$HOMEBREW_PREFIX/sbin:$PATH"
if [ -f $HOMEBREW_PREFIX/etc/bash_completion ]; then
        source $HOMEBREW_PREFIX/etc/bash_completion
fi
```
Then do:

```
source ~/.bash_profile
git clone https://github.com/Homebrew/homebrew.git $HOMEBREW_PREFIX
mkdir $HOMEBREW_TEMP
```

That's it. 

## Challange it!

Done? Test it:

* `env` Check `HOMEBREW_PREFIX`, `HOMEBREW_CACHE`, `HOMEBREW_TEMP` and `PATH`.
* `brew doctor` Understand? Warnings are warnings are warnings.
* `brew install wget`
* `which wget`
* `ls -al $(brew --prefix)/bin`
* `man wget`

Test it harder:

* `brew install homebrew/php/php55`
* `brew install python perl ruby git ansible`
* `brew install gcc`

Make it more comfortable: 
* `brew install bash-completion`
* `source $(brew --prefix)/etc/bash_completion`
* `brew [tab][tab]`
* `brew tap homebrew/completions`
* `brew install vagrant-completion`
* `source $(brew --prefix)/etc/bash_completion`
* `vagrant [tab][tab]`
* Visit https://github.com/Homebrew/homebrew-completions

## Why to do?

Well, if your read so far, you have your personal reason. Other reasons:

* You don't want to ring the admin.
* You want to separate Apples OS and your own beer, maybe on different partitions.
* You want your breewings on an USB-Stick to have them available on multiple machines.
* You want to have different setups for different Users.
* You want different exchangable setups of homebrew on different prefixes.

## Casks

Installing casks is NOT homebrewing. Instead the beer is delivered from the brewery and just sold under the label of Homebrew. You have to accept the terms given by the brewery. That means in many cases you can't simply install the applications into your users directoy and admin privileges are required. However there are some tricks to circumvent the limitations. As it is not homebrewing, I give it a [separate chapter](CasksAtHome.md).


