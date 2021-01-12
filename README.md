## Mac OS HoMM3 installer

This short script will help you installing and running Heroes of Might and Magic 3, HoMM3 HD edition and Horn of the Abyss (HotA) on your older Mac OS. You need to do just one thing before you start the process: download the two offline HoMM3 installer files (~1 GB) from [gog.com](https://www.gog.com/account) (I assume you bought the game before).

The whole project's aim is to automatize [this](https://rogulski.it/blog/heroes-3-on-wine/) well-written install guide.

## Prerequisites

- A Macbook with Yosemite, El Capitan, Sierra, High Sierra or Mojave with the latest update. If you are using Catalina or Big Sur, check [this](https://github.com/anton-pavlov/homm3_docker) method insted of this.
- Downloaded HoMM3 offline installer files from gog.com.

## Install

1 - Open Terminal (hit `Command+Space` -> type `Terminal` and hit `Enter`).

<p align="center">
  <a href="docs/images/open_terminal.png"><img src="docs/images/open_terminal.png" width="400" alt="Open Terminal" /></a>
</p>

2 - Enter the following command:

```/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Peneheals/ihhh/master/install_homm3.sh)"```

<p align="center">
  <a href="docs/images/curl_run.png"><img src="docs/images/curl_run.png" width="400" alt="Run the script" /></a>
</p>

## Alternative install method

1 - Download the code.

<p align="center">
  <a href="docs/images/download_zip.png"><img src="docs/images/download_zip.png" width="400" alt="Download the code" /></a>
</p>

2 - Click on it to unzip.

<p align="center">
  <a href="docs/images/open_zip.png"><img src="docs/images/open_zip.png" width="400" alt="Unzip the package" /></a>
</p>

3 - Check that it is in the right place (I assume your DLs go to your home's `Downloads` folder).

<p align="center">
  <a href="docs/images/unzipped_zip.png"><img src="docs/images/unzipped_zip.png" width="400" alt="Check the files" /></a>
</p>

4 - Open Terminal (hit `Command+Space` -> type `Terminal` and hit `Enter`).

<p align="center">
  <a href="docs/images/open_terminal.png"><img src="docs/images/open_terminal.png" width="400" alt="Open Terminal" /></a>
</p>

5 - Run the script.

<p align="center">
  <a href="docs/images/run_script.png"><img src="docs/images/run_script.png" width="400" alt="Run the script" /></a>
</p>

## Uninstall

TODO

## Run the game after the install

1. Just open a Terminal (see above how).
1. Enter

```cd "$HOME/.wine/drive_c/GOG\ Games/HoMM\ 3\ Complete" && wine HD_Launcher.exe```

## Contribute

If you have any feedback (feature requests, bug reports, problems etc.), feel free to open an issue [here](https://github.com/Peneheals/ihhh/issues/new). Please upload any related screenshots (maybe to [Imgur](https://imgur.com/)) and link them in the issue.

## Good to know

1. The installer uses common and existing tools:
    1. [Brew](https://brew.sh), to install necessary packages.
    1. [Wine](https://www.winehq.org/), to run the Windows-based game in Mac.
    1. [HD mod](https://sites.google.com/site/heroes3hd/eng/download) and [HotA](https://www.vault.acidcave.net/).
    1. Planned: [this](https://github.com/nicohman/wyvern) or [this](https://github.com/Sude-/lgogdownloader) to download the offline installer files from GoG.
1. We do not store nor send any credentials to any 3rd party (except gog.com in a future release).
1. Planned: Linux support!

## Copyright

TODO
