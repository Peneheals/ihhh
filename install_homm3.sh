#!/usr/bin/env bash

# Set some vars, colors, texts, files, URLs etc.
set -e
RED=`tput setaf 1; tput bold`
GREEN=`tput setaf 2; tput bold`
YELLOW=`tput setaf 3; tput bold`
BOLD=`tput bold`
NC=`tput sgr0`
AOK=`printf ${BOLD}[${GREEN}OK${NC}${BOLD}]${NC}`
AERROR=`printf ${BOLD}[${RED}FALSE${NC}${BOLD}]${NC}`
AINFO=`printf ${BOLD}[${YELLOW}INFO${NC}${BOLD}]${NC}`
AHR=`printf ${RED}###########################################################################${NC}`
INSECURE="--insecure|-k"
HOMM3CEXE="$HOME/Downloads/setup_heroes_of_might_and_magic_3_complete_4.0_(28740).exe"
HOMM3CBIN="$HOME/Downloads/setup_heroes_of_might_and_magic_3_complete_4.0_(28740)-1.bin"
HOMM3HD="$HOME/Downloads/HoMM3_HD_Latest_setup.exe"
HOMM3HOTA="$HOME/Downloads/HotA_1.6.1_setup.exe"
WINEPKG="http://dl.winehq.org/wine-builds/macosx/pool/winehq-stable-4.0.3.pkg"
WINE="/Applications/Wine Stable.app/Contents/Resources/wine/bin/wine"
FOLDERS="GOG Games/HoMM 3 Complete"
WINEHOMM3C="$HOME/.wine/drive_c/$FOLDERS/Heroes3.exe"
WINEHOMM3HD="$HOME/.wine/drive_c/$FOLDERS/HD_Launcher.exe"
WINEHOMM3HOTA="$HOME/.wine/drive_c/$FOLDERS/HotA_launcher.exe"
ICON="$HOME/Desktop/homm3.app"

# Check OS. At the moment Mac Catalina (or above) is not supported, neither Mavericks (or below).
# 14 - Yosemite, 15 - El Capitan, 16 - Sierra, 17 - High Sierra, 18 - Mojave etc.
echo_check_os_type () {
  if ((${OSTYPE:6} >= 14 && ${OSTYPE:6} <= 18)); then
    printf "\n${AHR}\n%s\n%s\n%s\n%s\n" "${AOK} Your Mac OS type is ${OSTYPE:6}." "${AINFO} You might have to provide multiple times your admin password during the process," "select the correct install locations and allow or deny packages to install (check the help messages!)." "${AINFO} The whole install process ${BOLD}can take half an hour${NC}!"
    printf "%s${AHR}\n\n" ""
  else
    printf "\n%s\n%s\n\n" "${AERROR} This installer is not suitable for macOS Catalina or Big Sur. Try this instead: https://github.com/anton-pavlov/homm3_docker" "And we are not supporting OS X Mavericks (or below) at the moment, try installing manually. Aborting..."
    exit 1
  fi
}

# Install xcode-select. Opens a dialog prompt.
install_xs () {
  xcode-select --install
  printf "\n%s\n\n" "${AOK} xcode-select has been installed."
}

# Install Homebrew.
install_homebrew () {
  if [[ $(command -v brew) == "" ]]; then
#    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    printf "\n%s\n\n" "${AOK} Homebrew installed."
  else
    brew update
    printf "\n%s\n\n" "${AOK} Homebrew updated."
#    brew doctor
  fi
}

# Install Git.
install_git () {
  if brew list git; then
    printf "\n%s\n\n" "${AOK} Git is installed."
  else
    if ((${OSTYPE:6} >= 14 && ${OSTYPE:6} <= 17)); then
      if [ -f "$HOME/.curlrc" ]; then
        if grep -qrHnE -- "${INSECURE}" $HOME/.curlrc ; then
          :
        else
          mv -f "$HOME/.curlrc" "$HOME/.curlrc.old"
          printf "%s\n" "--insecure" > $HOME/.curlrc
        fi
      else
        printf "%s\n" "--insecure" > $HOME/.curlrc
        NEWCURLRC="1"
      fi
      brew install --build-from-source git
      if [ -f "$HOME/.curlrc.old" ]; then
        rm -rf "$HOME/.curlrc"
        mv -f "$HOME/.curlrc.old" "$HOME/.curlrc"
      fi
      if [[ NEWCURLRC == 1* ]]; then
        rm -rf "$HOME/.curlrc"
      fi
      printf "\n%s\n\n" "${AOK} Git has been installed."
    else
      if brew ls --versions git > /dev/null; then
        brew upgrade git
	      printf "\n%s\n\n" "${AOK} Git is installed."
      else
        brew install git
        printf "\n%s\n\n" "${AOK} Git has been installed."
      fi
    fi
  fi
}

# Install XQuartz.
install_xquartz () {
  if brew list --cask xquartz; then
    printf "\n%s\n\n" "${AOK} XQuartz is installed."
  else
    brew install --cask xquartz
    printf "\n%s\n\n" "${AOK} XQuartz has been installed."
  fi
}

# Install Wine. Mono and Gecko is not necessary.
install_wine () {
  if brew list --cask wine-stable; then
    printf "\n%s\n\n" "${AOK} Wine stable is installed."
  else
    if ((${OSTYPE:6} >= 14 && ${OSTYPE:6} <= 17)); then
      # brew install wine --force-bottle
      printf "\n${AHR}\n%s\n${AHR}\n\n" "Installing Wine stable."
      sleep 2
      brew install --cask wine-stable
      printf "\n%s\n\n" "${AOK} Wine stable has been installed."
    else
      if brew ls --versions wine > /dev/null; then
	      printf "\n%s\n\n" "${AOK} Wine is installed."
      else
        brew install wine
        printf "\n%s\n\n" "${AOK} Wine has been installed."
      fi
    fi
  fi
}

# Install Wine from package (http://dl.winehq.org/wine-builds/macosx/pool/). Not used at the moment.
install_winepkg () {
  export WINEPREFIX=/Volumes/Exfat4life/WINE
  curl --silent --show-error --location --output "$HOME/Downloads/winehq-stable-4.0.3.pkg" "$WINEPKG"
  mkdir -p "$WINEPREFIX"
  sudo installer -pkg "$HOME/Downloads/winehq-stable-4.0.3.pkg" -target "$WINEPREFIX"
  ln -s  "${WINE}" /usr/local/bin/wine
}

# Check prerequisites. At the moment the two core install files have to be downloaded from gog.com (after purchasing HOMM3 Complete).
echo_prerequisites () {
  printf "%s\n" "${RED}Download${NC} HOMM3 Complete's offline backup game installers (~1 MB and ~0.9 GB) from your GoG games library: https://www.gog.com/account"
  read -p "Enter '${RED}yes${NC}' to proceed if you've already downloaded the necessary installer fileparts to your '${RED}Downloads${NC}' folder. `echo $'\n> '`"
  if [[ $REPLY =~ ^yes$ ]]; then
    if [ -f "$HOMM3CEXE" ]; then
      printf "\n%s\n\n" "${AOK} HOMM3 Complete filepart #1 present."
      if [ -f "$HOMM3CBIN" ]; then
        printf "%s\n\n" "${AOK} HOMM3 Complete filepart #2 present."
      else
        printf "%s\n\n" "${AERROR} HOMM3 Complete filepart #2 missing. Download from gog.com. Aborting..."
        exit 1
      fi
    else
      printf "%s\n\n" "${AERROR} HOMM3 Complete filepart #1 missing. Download from gog.com. Aborting..."
      exit 1
    fi
  else
    printf "%s\n\n" "${AERROR} Aborting..."
    exit 1
  fi
}

# Download HOMM3 HD and HotA.
download_files () {
  printf "%s\n" "${RED}Downloading${NC} HD edition (~15 MB) from https://sites.google.com/site/heroes3hd/eng/download and HotA (~200 MB) from https://www.vault.acidcave.net/file.php?id=614"

  if [ -f "$HOMM3HD" ]; then
    printf "%s\n\n" "${AOK} HOMM3 HD installer exists."
  else
    curl --silent --show-error --location --output "$HOMM3HD" http://vm914332.had.yt/HoMM3_HD_Latest_setup.exe
    printf "\n%s\n\n" "${AOK} HOMM3 HD downloaded."
  fi

  if [ -f "$HOMM3HOTA" ]; then
    printf "%s\n\n" "${AOK} HOMM3 HotA installer exists."
  else
#    curl --silent --show-error --location --output "$HOMM3HOTA" https://www.vault.acidcave.net/download.php?id=598
    curl --silent --show-error --location --output "$HOMM3HOTA" https://www.vault.acidcave.net/download.php?id=614
    printf "%s\n\n" "${AOK} HOMM3 HotA downloaded."
  fi
}

# Install HoMM3.
# The "Error: unsupported compressor 8" errors are not relevant and can be ignored. HOMM3 with Wine is working well on APFS filesystem.
install_homm3 () {
  if [ -f "$WINEHOMM3C" ]; then
    printf "%s\n\n" "${AOK} HoMM3 Complete installed."
  else
    printf "${AHR}\n%s\n%s\n${AHR}\n\n" "Install HoMM3 into '${RED}C:\\${FOLDERS//\//\\}\\${NC}', select '${RED}Exit${NC}' at last step." "${RED}Mono${NC} and ${RED}Gecko${NC} packages are not necessary for HoMM3, skip them if asked."
    sleep 2
    "${WINE}" $HOMM3CEXE
  fi
}

# Install HoMM3 HD.
install_homm3hd () {
  if [ -f "$WINEHOMM3HD" ]; then
    printf "%s\n\n" "${AOK} HOMM3 HD installed."
  else
    printf "\n${AHR}\n%s\n${AHR}\n\n" "Install HoMM3 HD into '${RED}C:\\${FOLDERS//\//\\}\\${NC}', untick '${RED}Launch HoMM3 HD${NC}' at last step."
    sleep 2
    "${WINE}" $HOMM3HD
  fi
}

# Install HoMM3 HotA.
install_homm3_hota () {
  if [ -f "$WINEHOMM3HOTA" ]; then
    printf "%s\n\n" "${AOK} HOMM3 HotA installed."
  else
    printf "\n${AHR}\n%s\n${AHR}\n\n" "Install HotA into '${RED}C:\\${FOLDERS//\//\\}\\${NC}'."
    sleep 2
    "${WINE}" $HOMM3HOTA
  fi
}

# Update games. Not used at the moment.
update () {
  sleep 1
}

# Tweaking. Not used at the moment.
tweak () {
  sleep 1
}

# Create Desktop icon or Dock shortcut. Not used at the moment.
generate_shortcut () {
  if [ -f "$ICON" ]; then
    printf "%s\n\n" "${AOK} HoMM3 shortcut is present."
  else
    cat <<EOT >> "$ICON"
tell application "Terminal"
  do script " ${WINE} $HOME/.wine/drive_c/${FOLDERS}/HD_launcher.exe"
end tell
EOT
    chmod 0755 "$ICON"
    printf "%s\n\n" "${AOK} HoMM3 shortcut has been created on Desktop."
  fi
}

end_message () {
  printf "\n${AHR}\n%s\n\n" "${RED}How to run the game after the install process:${NC}"
  printf "%s\n" "${RED}1.${NC} Run the following command in the Terminal (CMND+Space -> Terminal) to start the HD launcher:"
  printf "%s\n" "${RED}cd \"$HOME/.wine/drive_c/${FOLDERS}\" && wine HD_Launcher.exe${NC}"
  printf "%s\n" "${RED}2.${NC} Check for updates with '${RED}Update${NC}' button and install it if you found any!"
  printf "%s\n" "${RED}3.${NC} If the basic settings (resolution etc.) look OK, create the HD.exe with the '${RED}Create HD exe${NC}' button!"
  printf "%s\n" "${RED}4.${NC} Now you are ready to play! The above steps are not necessary in the future, just start the launcher in the Terminal with the above command (or push the up key for last executed command) and hit the '${RED}Play${NC}' button!"
  # printf "%s\n\n" "Locate the Desktop icon and start it! :)"
  printf "%s${AHR}\n\n" ""
}

echo_check_os_type
install_xs
install_homebrew
install_git
install_xquartz
install_wine
#install_winepkg
echo_prerequisites
download_files
install_homm3
install_homm3hd
install_homm3_hota
#update
#tweak
#generate_shortcut
end_message
