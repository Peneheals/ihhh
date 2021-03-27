#!/usr/bin/env bash

# Set some vars, colors, texts, files, URLs etc.
# Let the script fail and immediately exit on any error.
set -e
ARGNUM="$#"
ARGONE="$1"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
RED=`tput setaf 1; tput bold`
GREEN=`tput setaf 2; tput bold`
YELLOW=`tput setaf 3; tput bold`
BOLD=`tput bold`
NC=`tput sgr0`
AOK=`printf ${BOLD}[${GREEN}OK${NC}${BOLD}]${NC}`
AERROR=`printf ${BOLD}[${RED}ERROR${NC}${BOLD}]${NC}`
AINFO=`printf ${BOLD}[${YELLOW}INFO${NC}${BOLD}]${NC}`
AHR=`printf ${RED}###########################################################################${NC}`
HOMM3CEXE="${HOME}/Downloads/setup_heroes_of_might_and_magic_3_complete_4.0_(28740).exe"
HOMM3CBIN="${HOME}/Downloads/setup_heroes_of_might_and_magic_3_complete_4.0_(28740)-1.bin"
HOMM3HD="${HOME}/Downloads/HoMM3_HD_Latest_setup.exe"
HOMM3HOTA="${HOME}/Downloads/HotA_1.6.1_setup.exe"
WINEPKG="http://dl.winehq.org/wine-builds/macosx/pool/winehq-stable-4.0.3.pkg"
WINE="/Applications/Wine Stable.app/Contents/Resources/wine/bin/wine"
FOLDERS="GOG Games/HoMM 3 Complete"
WINEHOMM3C="${HOME}/.wine/drive_c/${FOLDERS}/Heroes3.exe"
WINEHOMM3HD="${HOME}/.wine/drive_c/${FOLDERS}/HD_Launcher.exe"
WINEHOMM3HOTA="${HOME}/.wine/drive_c/${FOLDERS}/HotA_launcher.exe"
ICON="${HOME}/Desktop/homm3.app"

# Exit if we are root.
check_root () {
  if [ $(id -u) = 0 ]; then
   printf "\n\a%s\n" "You shouldn't run this installer as root! Aborting..."
   exit 1
 fi
}

# Uninstaller - It wipes EVERYTHING!
uninstall () {
  check_root
  printf "\n\a%s${AHR}\n" ""
  read -p "${RED}WARNING!${NC} The uninstaller will wipe everything that HoMM3 needs for running, including ${RED}Homebrew${NC} and all the formulas/casks, ${RED}Wine${NC} and all your Wine-installed programs, ${RED}HoMM3${NC} and every mods and ${RED}all your saved games${NC}! Enter '${RED}yes${NC}' to proceed if you are OK with the above. `echo $'\n> '`" </dev/tty
  if [[ $REPLY =~ ^yes$ ]]; then
    cd "${HOME}"
    if [[ $(command -v brew) == "" ]]; then
      printf "\n%s\n\n" "${AOK} Homebrew is in uninstalled state."
    else
      brew remove --cask --force --ignore-dependencies wine-stable
      sudo rm -rf "/Applications/Wine Stable.app/"
      rm -rf "${HOME}/.local/"
      rm -rf "${HOME}/.wine/"
      rm -rf "${HOME}/Library/Caches/Wine/"
      printf "\n%s\n" "${AOK} Wine was deleted."
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall.sh)"
      printf "\n%s\n" "${AOK} Homebrew was uninstalled."
    fi
    sudo rm -rf "/Library/Developer/CommandLineTools"
    sudo xcode-select -r
    printf "\n%s\n" "${AOK} xcode-select has been reset and command line tools default folder was deleted."
    rm -rf "$HOMM3HD"
    printf "\n%s\n" "${AOK} HoMM3 HD installer was deleted."
    rm -rf "$HOMM3HOTA"
    printf "\n%s\n\n" "${AOK} HoMM3 HotA installer was deleted."
    exit 0
  else
    printf "%s\n\n" "${AERROR} Aborting..." >&2
    exit 1
  fi
}

# Uninstall HoMM3 - Delete ${HOME}/.wine completely!
uninstall_homm3 () {
  check_root
  printf "\n\a%s${AHR}\n" ""
  read -p "${RED}WARNING!${NC} The HoMM3 uninstaller will wipe your ${HOME}/.wine directory and therefore ${RED}HoMM3${NC} and every mods and ${RED}all your saved games${NC}! Enter '${RED}yes${NC}' to proceed if you are OK with the above. `echo $'\n> '`" </dev/tty
  if [[ $REPLY =~ ^yes$ ]]; then
    cd "${HOME}"
    rm -rf "${HOME}/.wine/"
    printf "\n%s\n" "${AOK} .wine directory was deleted."
    rm -rf "$HOMM3HD"
    printf "\n%s\n" "${AOK} HoMM3 HD installer was deleted."
    rm -rf "$HOMM3HOTA"
    printf "\n%s\n\n" "${AOK} HoMM3 HotA installer was deleted."
    exit 0
  else
    printf "%s\n\n" "${AERROR} Aborting..." >&2
    exit 1
  fi
}

# Check the given option's validity.
check_arg () {
  if [ "${ARGNUM}" -eq "0" ]; then
    :
  elif [ "${ARGNUM}" -gt "1" ]; then
    printf "\n${AERROR} Invalid option, use none or one script argument.\n" >&2
    exit 1
  else
    PATTERN='^[3a-z_-]*$'
    if [[ $ARGONE =~ $PATTERN ]]; then
      if ([ "${ARGONE}" == "--uninstall" ] || [ "${ARGONE}" == "-u" ]); then
        uninstall
      elif ([ "${ARGONE}" == "--uninstall-homm3" ] || [ "${ARGONE}" == "-uh3" ]); then
        uninstall_homm3
      elif ([ "${ARGONE}" == "--help" ] || [ "${ARGONE}" == "-h" ]); then
        printf "\n${AINFO} The only valid options are:\n '--uninstall' - to uninstall everything, and\n '--uninstall-homm3' - to uninstall HoMM3 (delete ${HOME}/.wine directory).\n" >&2
        exit 1
      else
        printf "\n${AINFO} Invalid option, continuing.\n"
        :
      fi
    else
      printf "\n${AERROR} Invalid option! Use lower case English alphabet and/or "-" characters.\n" >&2
      exit 1
    fi
  fi
}

# Check OS. At the moment Catalina (or above) is not supported, neither Mavericks (or below).
check_os () {
  OSVER=$(/usr/bin/sw_vers -productVersion)
  SPLITOSVER=( ${OSVER//./ } )
  SHORTOSVER="${SPLITOSVER[0]}.${SPLITOSVER[1]}"
  if ([ "${SPLITOSVER[0]}" == "11" ]); then
    OSNAME="macOS Big Sur"
  else
    curl --silent --show-error --location --output "/tmp/macos.versions" https://raw.githubusercontent.com/Peneheals/ihhh/master/assets/macos.versions
    OSNAME=$(sed -n "/$SHORTOSVER/s/$SHORTOSVER//p" "/tmp/macos.versions" )
  fi
  if ((${OSTYPE:6} >= 14 && ${OSTYPE:6} <= 18)); then
    printf "\n${AHR}\n\a%s\n%s\n%s\n%s\n%s\n" "${AOK} Your Mac OS is ${OSNAME}, version is ${OSVER}, type is ${OSTYPE:6}." "${AINFO} You might have to provide multiple times your admin password during " "the process, select the correct install locations and allow or deny" "packages to install (check the help messages!)." "${AINFO} The whole install process ${BOLD}can take half an hour${NC}!"
    printf "%s${AHR}\n\n" ""
  else
    printf "\n\a%s\n%s\n%s\n\n" "${AERROR} Your Mac OS is ${OSNAME}, version is ${OSVER}, type is ${OSTYPE:6}." "This installer is not suitable for macOS Catalina or Big Sur. Try this instead: https://github.com/anton-pavlov/homm3_docker" "We also do not support OS X Mavericks (or below) at the moment, try installing manually. Aborting..." >&2
    exit 1
  fi
}

# Curl insecure fix on.
curl_insecure_fix_on () {
  curl --silent --time-cond "${HOME}/Downloads/cacert.pem" --output "${HOME}/Downloads/cacert.pem" https://curl.se/ca/cacert.pem
  if [ -f "${HOME}/.curlrc" ]; then
    mv -f "${HOME}/.curlrc" "${HOME}/.curlrc.old"
  fi
  printf "%s\n%s\n%s\n%s\n%s\n" "--fail" "--insecure" "--location" "--show-error" "cacert=${HOME}/Downloads/cacert.pem" > "${HOME}/.curlrc"
  export HOMEBREW_CURLRC=1
}

# Curl insecure fix off.
curl_insecure_fix_off () {
  rm -rf "${HOME}/.curlrc"
  if [ -f "${HOME}/.curlrc.old" ]; then
    mv -f "${HOME}/.curlrc.old" "${HOME}/.curlrc"
  fi
}

# Install xcode-select. Opens a dialog prompt.
install_xs () {
  if xcode-select --print-path >/dev/null 2>&1 && xcode-select --version | grep -qE "^xcode-select version 23[0-9]{2}.$" ; then
    if ((${OSTYPE:6} < 18)); then
      if [[ -f "/Library/Developer/CommandLineTools/usr/bin/git" && -f "/usr/include/iconv.h" ]]; then
        printf "\n%s\n\n" "${AOK} xcode-select is installed."
      else
        xcode-select --install
        printf "\n%s\n\n" "${AOK} xcode-select is installing, check the dialog box. Return to this terminal when its done."
      fi
    else
      if [ -f "/Library/Developer/CommandLineTools/usr/bin/git" ]; then
        printf "\n%s\n\n" "${AOK} xcode-select is installed."
      else
        xcode-select --install
        printf "\n%s\n\n" "${AOK} xcode-select is installing, check the dialog box. Return to this terminal when its done."
      fi
    fi
  else
    xcode-select --install
    printf "\n%s\n\n" "${AOK} xcode-select is installing, check the dialog box. Return to this terminal when its done."
  fi
}

# Install Git.
install_git () {
  if brew list git; then
    printf "\n%s\n\n" "${AOK} Git is installed."
  else
    if ([ "${OSTYPE:6}" == "14" ]); then
      # Yosemite's built-in git is garbage, we have to use another solution.
      brew install --build-from-source git
      printf "\n%s\n\n" "${AOK} Git has been installed."
    elif ((${OSTYPE:6} >= 15 && ${OSTYPE:6} <= 17)); then
      export HOMEBREW_FORCE_BREWED_CURL=1
      export HOMEBREW_SYSTEM_CURL_TOO_OLD=1
      brew install --build-from-source git
      printf "\n%s\n\n" "${AOK} Git has been installed."
    else
      if brew ls --versions git >/dev/null; then
        brew upgrade git
	printf "\n%s\n\n" "${AOK} Git is installed."
      else
        brew install git
        printf "\n%s\n\n" "${AOK} Git has been installed."
      fi
    fi
  fi
}

# Install Homebrew.
install_homebrew () {
  if [[ $(command -v brew) == "" ]]; then
    if ([ "${OSTYPE:6}" == "14" ]); then
      curl_insecure_fix_on
      # Yosemite always fails at the first Brew install attempt.
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || :
      # Yosemite's built-in curl and openssl is garbage, we have to build ours.
      # Give this a try later: https://github.com/jasonacox/Build-OpenSSL-cURL
      cd "${HOME}/Downloads"
      curl --progress-bar --output "${HOME}/Downloads/OpenSSL_1_1_1j.tar.gz" https://github.com/openssl/openssl/archive/refs/tags/OpenSSL_1_1_1j.tar.gz
      tar -xzf "OpenSSL_1_1_1j.tar.gz"
      cd "openssl-OpenSSL_1_1_1j"
      ./Configure darwin64-x86_64-cc shared enable-ec_nistp_64_gcc_128 no-ssl2 no-ssl3 no-comp --openssldir=/usr/local/ssl
      make depend
      sudo make install
      cd "${HOME}/Downloads"
      rm -rf "OpenSSL_1_1_1j.tar.gz"
      rm -rf "openssl-OpenSSL_1_1_1j"
      sudo chown -R $(whoami) /usr/local/share/
      sudo chown -R $(whoami) /usr/local/lib/
      # If we do not install this, we end up with a useless curl.
      # dyld: lazy symbol binding failed: Symbol not found: _OpenSSL_version_num
      # Referenced from: /usr/local/lib/libcurl.4.dylib Expected in: flat namespace
      brew install pkg-config
      # Now we are ready to build curl with working openssl.
      curl --progress-bar --output "${HOME}/Downloads/curl-7.75.0.tar.gz" https://github.com/curl/curl/releases/download/curl-7_75_0/curl-7.75.0.tar.gz
      tar -xzf "curl-7.75.0.tar.gz"
      cd "curl-7.75.0"
      ./configure --with-ssl
      make
      make install
      cd "${HOME}/Downloads"
      rm -rf "curl-7.75.0.tar.gz"
      rm -rf "curl-7.75.0"
      # Bypass Yosemite's curl bug: https://github.com/curl/curl/issues/998
      # We have to use the below hack because `brew link --force curl` isn't
      # working either and without that we can't bypass the SNI issue.
      if [[ -L "/usr/bin/curl" && -f "/usr/bin/curl" ]]; then
      	:
      else
      	sudo mv -f "/usr/bin/curl" "/usr/bin/curl.old"
      	sudo ln -s "/usr/local/bin/curl" "/usr/bin/curl"
      fi
      install_git
      sudo mv -f /usr/bin/git /usr/bin/git.old
      sudo ln -s /usr/local/bin/git /usr/bin/git
      # Resolve the below Apple+git certificate error:
      # fatal: unable to access 'https://github.com/Homebrew/brew/':
      # SSL certificate problem: unable to get local issuer certificate
      # Failed during: git fetch --force origin
      git config --global http.https://github.com/.sslVerify false
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      curl_insecure_fix_off
      # sudo rm -rf "/usr/bin/curl"
      # sudo mv -f "/usr/bin/curl.old" "/usr/bin/curl"
      # sudo rm -rf "/usr/bin/git"
      # sudo mv -f "/usr/bin/git.old" "/usr/bin/git"
    else
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    printf "\n%s\n\n" "${AOK} Homebrew installed."
  else
    brew update
    printf "\n%s\n\n" "${AOK} Homebrew updated."
  fi
}

# Install XQuartz.
install_xquartz () {
  curl_insecure_fix_on
  if brew list --cask xquartz; then
    printf "\n%s\n\n" "${AOK} XQuartz is installed."
  else
    brew install --cask xquartz
    printf "\n%s\n\n" "${AOK} XQuartz has been installed."
  fi
  curl_insecure_fix_off
}

# Install Wine.
install_wine () {
  curl_insecure_fix_on
  if brew list --cask wine-stable; then
    printf "\n%s\n\n" "${AOK} Wine stable is installed."
  else
    if ((${OSTYPE:6} >= 14 && ${OSTYPE:6} <= 18)); then
      # Install Wine without Mono and Gecko.
      export WINEDLLOVERRIDES="mscoree,mshtml="
      brew install --cask wine-stable
      printf "\n%s\n\n" "${AOK} Wine stable has been installed."
    else
      if brew ls --versions wine >/dev/null; then
        printf "\n%s\n\n" "${AOK} Wine is installed."
      else
        export WINEDLLOVERRIDES="mscoree,mshtml="
        brew install wine
        printf "\n%s\n\n" "${AOK} Wine has been installed."
      fi
    fi
  fi
  curl_insecure_fix_off
}

# Install Wine from package (http://dl.winehq.org/wine-builds/macosx/pool/). Not used at the moment.
install_winepkg () {
  export WINEPREFIX=/Volumes/Exfat4life/WINE
  curl --progress-bar --output "${HOME}/Downloads/winehq-stable-4.0.3.pkg" "$WINEPKG"
  mkdir -p "$WINEPREFIX"
  sudo installer -pkg "${HOME}/Downloads/winehq-stable-4.0.3.pkg" -target "$WINEPREFIX"
  ln -s  "${WINE}" "/usr/local/bin/wine"
}

# Install Rust, Cargo and Wyvern, then download offline game installers from gog.com.
install_cargo () {
  curl_insecure_fix_on
  if ((${OSTYPE:6} >= 14 && ${OSTYPE:6} <= 15)); then
    :
  else
    brew install rust
    cargo install wyvern
    if grep -qrHnE -- "Inserted by HoMM3 installer" "${HOME}/.bashrc" ; then
      :
    else
      printf 'export PATH="${HOME}/.cargo/bin:$PATH" # Inserted by HoMM3 installer.' >> "${HOME}/.bashrc"
      . "${HOME}/.bashrc"
    fi
    read -p "Enter your '${RED}gog.com username${NC}' to proceed and download necessary HoMM3 files. `echo $'\n> '`"
    wyvern login --username "${REPLY}"
    # 1207658787 is the GoG ID of HoMM3 Complete
    wyvern down -w -i 1207658787 -o "${HOME}/Downloads/"
  fi
  curl_insecure_fix_off
}

# Check prerequisites.
echo_prerequisites () {
  if ((${OSTYPE:6} >= 14 && ${OSTYPE:6} <= 15)); then
    printf "\a%s\n" "${RED}Download${NC} HoMM3 Complete's offline backup game installers (~1 MB and ~0.9 GB) from your GoG games library: https://www.gog.com/account"
    read -p "Enter '${RED}yes${NC}' to proceed if you've already downloaded the necessary installer fileparts to your '${RED}Downloads${NC}' folder. `echo $'\n> '`"
  else
    REPLY=yes
  fi

  if [[ $REPLY =~ ^yes$ ]]; then
    if [ -f "$HOMM3CEXE" ]; then
      printf "\n%s\n\n" "${AOK} HoMM3 Complete filepart #1 exists: $HOMM3CEXE"
      if [ -f "$HOMM3CBIN" ]; then
        printf "%s\n\n" "${AOK} HoMM3 Complete filepart #2 exists: $HOMM3CBIN"
      else
        printf "%s\n%s\n\n" "${AERROR} HoMM3 Complete filepart #2 is missing: $HOMM3CBIN" "Download from gog.com. Aborting..." >&2
        exit 1
      fi
    else
      printf "%s\n%s\n\n" "${AERROR} HoMM3 Complete filepart #1 is missing: $HOMM3CEXE" "Download from gog.com. Aborting..." >&2
      exit 1
    fi
  else
    printf "%s\n\n" "${AERROR} Aborting..." >&2
    exit 1
  fi
}

# Download HoMM3 HD and HotA.
download_files () {
  curl_insecure_fix_on
  printf "%s\n%s\n" "${RED}Downloading${NC} HD edition (~15 MB) from https://sites.google.com/site/heroes3hd/eng/download" "and HotA (~200 MB) from https://www.vault.acidcave.net/file.php?id=614 to ${HOME}/Downloads"

  if [ -f "$HOMM3HD" ]; then
    printf "%s\n\n" "${AOK} HoMM3 HD installer exists: $HOMM3HD"
  else
    curl --progress-bar --output "$HOMM3HD" http://vm914332.had.yt/HoMM3_HD_Latest_setup.exe
    printf "\n%s\n\n" "${AOK} HoMM3 HD downloaded to $HOMM3HD"
  fi

  if [ -f "$HOMM3HOTA" ]; then
    printf "%s\n\n" "${AOK} HoMM3 HotA installer exists: $HOMM3HOTA"
  else
    curl --progress-bar --output "$HOMM3HOTA" https://www.vault.acidcave.net/download.php?id=614
    printf "%s\n\n" "${AOK} HoMM3 HotA downloaded to $HOMM3HOTA"
  fi
  curl_insecure_fix_off
}

# Install HoMM3 without user interaction.
# The "Error: unsupported compressor 8" errors are not relevant and can be ignored.
# HoMM3 with Wine is working well on APFS filesystem.
install_homm3 () {
  if [ -f "$WINEHOMM3C" ]; then
    printf "%s\n\n" "${AOK} HoMM3 Complete installed."
  else
    export WINEDLLOVERRIDES="mscoree,mshtml="
    printf "${AHR}\n%s\n${AHR}\n\n" "Installing HoMM3 into '${RED}${HOME}/.wine/drive_c/${FOLDERS}/${NC}' (Windows path: '${RED}C:\\${FOLDERS//\//\\}\\${NC}')."
    "${WINE}" $HOMM3CEXE /verysilent /supportDir="C:\GOG Games\HoMM 3 Complete\__support" /SUPPRESSMSGBOXES /NORESTART /DIR="C:\GOG Games\HoMM 3 Complete" /productId="1207658787" /buildId="52179602202150698" /versionName="4.0" /Language="English" /LANG="english"
  fi
}

# Install HoMM3 HD without user interaction.
install_homm3hd () {
  if [ -f "$WINEHOMM3HD" ]; then
    printf "%s\n\n" "${AOK} HoMM3 HD installed."
  else
    printf "\n${AHR}\n%s\n${AHR}\n\n" "Installing HoMM3 HD into '${RED}${HOME}/.wine/drive_c/${FOLDERS}/${NC}' (Windows path: '${RED}C:\\${FOLDERS//\//\\}\\${NC}')."
    "${WINE}" $HOMM3HD /verysilent /supportDir="C:\GOG Games\HoMM 3 Complete\__support" /SUPPRESSMSGBOXES /NORESTART /DIR="C:\GOG Games\HoMM 3 Complete"
  fi
}

# Install HoMM3 HotA without user interaction.
install_homm3_hota () {
  if [ -f "$WINEHOMM3HOTA" ]; then
    printf "%s\n\n" "${AOK} HoMM3 HotA installed."
  else
    printf "\n${AHR}\n%s\n${AHR}\n\n" "Installing HotA into '${RED}${HOME}/.wine/drive_c/${FOLDERS}/${NC}' (Windows path: '${RED}C:\\${FOLDERS//\//\\}\\${NC}')."
    "${WINE}" $HOMM3HOTA /verysilent /supportDir="C:\GOG Games\HoMM 3 Complete\__support" /SUPPRESSMSGBOXES /NORESTART /DIR="C:\GOG Games\HoMM 3 Complete" /Language="English" /LANG="english"
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
  do script " cd ${HOME}/.wine/drive_c/${FOLDERS}/ && ${WINE} HD_Launcher.exe"
end tell
EOT
    chmod 0755 "$ICON"
    printf "%s\n\n" "${AOK} HoMM3 shortcut has been created on Desktop."
  fi
}

end_message () {
  printf "\n${AHR}\n%s\n\n" "${RED}How to run the game after the install process:${NC}"
  printf "%s\n" "${RED}1.${NC} Run the following command in the Terminal (CMND+Space -> Terminal) to start the HD launcher:"
  printf "%s\n" "${RED}cd \"${HOME}/.wine/drive_c/${FOLDERS}\" && wine HD_Launcher.exe${NC}"
  printf "%s\n" "${RED}2.${NC} Check for updates with '${RED}Update${NC}' button and install it if you found any!"
  printf "%s\n" "${RED}3.${NC} If the basic settings (resolution etc.) look OK, create the HD.exe with the '${RED}Create HD exe${NC}' button!"
  printf "%s\n" "${RED}4.${NC} Now you are ready to play! The above steps are not necessary in the future, just start the launcher in the Terminal with the above command (or push the up key for last executed command) and hit the '${RED}Play${NC}' button!"
  # printf "%s\n\n" "Locate the Desktop icon and start it! :)"
  printf "%s${AHR}\n\n" ""
}

check_root
check_arg
check_os
install_xs
install_homebrew
install_git
install_xquartz
install_wine
#install_winepkg
install_cargo
echo_prerequisites
download_files
install_homm3
if ([ "${OSTYPE:6}" != "14" ]); then
  install_homm3hd
  install_homm3_hota
fi
#update
#tweak
#generate_shortcut
end_message
set +e
