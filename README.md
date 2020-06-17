# Jamf Homebrew Tap

_Jamf tools for macOS, distributed via Homebrew_

## Getting Started

This repository is a [Homebrew tap](https://docs.brew.sh/brew-tap.html) for
Jamf tools. After [installing Homebrew](https://brew.sh), add this
repository as a tap:

    brew tap jamf/tap

Done!

## Installing Tools From the Tap

After setting up the tap, install any of the available tools just like any
regular Homebrew package. For example:

    brew install jamf-pro

Check out the formulas in this repository to see what is available.

## Beta Releases

To install beta channel releases, instead of the stable ones, add a `--HEAD`
flag after the brew commands:

```shell
brew install jamf-pro --HEAD
```

## Contributing

Feel free to contribute! If you created a tool that might be useful to others,
add it here as a formula. Read Homebrew's excellent docs on [creating a
formula](https://docs.brew.sh/Formula-Cookbook.html) first. Then, open a pull
request and add at least one of the maintainers below as reviewer.

### Maintainers

* David Brazeau - david.brazeau@jamf.com
* Brandon Roehl - brandon.roehl@jamf.com
