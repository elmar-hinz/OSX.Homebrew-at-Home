# Homebrew at Home

*Or the Zen Path of Bootstrapping Your User*

Run **[Homebrew](http://brew.sh)** completely inside your home directory — as it's name promises — without ringing the admin. 

## Install

Customize your dotfiles i.e. `vim ~/.bash_profile`:

```
export HOMEBREW_PREFIX="$HOME/Library/Homebrew"
export HOMEBREW_TEMP="$HOMEBREW_PREFIX/Temp"
export HOMEBREW_CACHE="$HOME/Library/Caches/Homebrew"
export PATH="$HOMEBREW_PREFIX/bin:$PATH"
export PATH="$HOMEBREW_PREFIX/sbin:$PATH"
export HOMEBREW_CASK_OPTS="--appdir=$HOME/Applications --caskroom=$HOMEBREW_PREFIX/Caskroom"
if [ -f $HOMEBREW_PREFIX/etc/bash_completion ]; then
        source $HOMEBREW_PREFIX/etc/bash_completion
fi
```

Then run:

```
source ~/.bash_profile
git clone https://github.com/Homebrew/homebrew.git $HOMEBREW_PREFIX
mkdir $HOMEBREW_TEMP
brew tap homebrew/completions
brew install bash-completion
source ~/.bash_profile
brew install gem-completion
brew install caskroom/cask/brew-cask
brew cask install iterm2
```

Deeper explanation? See the docs!

## Docs

* [Homebrew at Home](HomebrewAtHome.md)
* [Casks at Home](CasksAtHome.md)

