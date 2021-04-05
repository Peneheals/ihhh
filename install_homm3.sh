#!/usr/bin/env bash

# Set some vars, colors, texts, files, URLs etc.
# Let the script fail and immediately exit on any error.
cd ${HOME}
set -e
ARGNUM="$#"
ARGONE="$1"
SCRIPTSTARTTIME=$(date +%s)
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
ICONFOLDER="${HOME}/Desktop/HoMM3.app/Contents/MacOS"
HOTAINI="${HOME}/.wine/drive_c/${FOLDERS}/_HD3_Data/Settings/hota.ini"

# Exit if we are root.
check_root () {
  if [ $(id -u) = 0 ]; then
   printf "\a\n%s\n" "You shouldn't run this installer as root! Aborting..."
   exit 1
 fi
}

# Simple timer to track rough elapsed time of separate install blocks.
function elapsed_time {
  if [[ "$1" == "" ]]; then
    printf '%dh %dm %ds' $((SECONDS/3600)) $((SECONDS%3600/60)) $((SECONDS%60)) | sed "s/0[hm][[:blank:]]//g"
  elif [[ "$1" == "end" ]]; then
    CURRTIME=$(date +%s)
    ELAPSED=$(( $CURRTIME - $SCRIPTSTARTTIME ))
    printf '%dh %dm %ds' $((ELAPSED/3600)) $((ELAPSED%3600/60)) $((ELAPSED%60)) | sed "s/0[hm][[:blank:]]//g"
  else
    printf "%s" ""
  fi
}

# Uninstaller - It wipes EVERYTHING!
uninstall () {
  SECONDS=0
  check_root
  printf "\a\n%s${AHR}\n" ""
  read -p "${RED}WARNING!${NC} The uninstaller will wipe everything that HoMM3 needs for running, including ${RED}Homebrew${NC} and all the formulas/casks, ${RED}Wine${NC} and all your Wine-installed programs, ${RED}HoMM3${NC} and every mods and ${RED}all your saved games${NC}! Enter '${RED}yes${NC}' to proceed if you are OK with the above. `echo $'\n> '`" </dev/tty
  if [[ $REPLY =~ ^yes$ ]]; then
    cd "${HOME}"
    # Brew & Wine & Xquartz
    if [[ $(command -v brew) == "" ]]; then
      printf "\n%s\n" "${AOK} Homebrew is in uninstalled state."
    else
      brew remove --cask --force --ignore-dependencies xquartz
      printf "\n%s\n" "${AOK} Xquartz was deleted."
      brew remove --cask --force --ignore-dependencies wine-stable
      sudo rm -rf "/Applications/Wine Stable.app/"
      rm -rf "${HOME}/.local/"
      rm -rf "${HOME}/.wine/"
      rm -rf "${HOME}/Library/Caches/Wine/"
      printf "\n%s\n" "${AOK} Wine was deleted."
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall.sh)"
      printf "\n%s\n" "${AOK} Homebrew was uninstalled."
    fi
    # Cargo & Wyvern
    if grep -qsrHnE -- "Inserted by HoMM3 installer" "${HOME}/.bashrc" ; then
      sed -i.bak -e '/Inserted by HoMM3 installer/d' "${HOME}/.bashrc" && rm -rf "${HOME}/.bashrc.bak"
      . "${HOME}/.bashrc"
    fi
    if [[ -d "${HOME}/.cargo/" ]]; then
      printf "\n%s\n" "${AOK} Cargo and Wyvern are in uninstalled state."
    else
      rm -rf "${HOME}/.cargo/"
      printf "\n%s\n" "${AOK} Cargo and Wyvern were deleted."
    fi
    # Command line tools (Xcode)
    sudo rm -rf "/Library/Developer/CommandLineTools"
    sudo xcode-select -r
    printf "\n%s\n" "${AOK} Xcode has been reset and command line tools default folder was deleted."
    # HoMM3 HD&HotA installer
    rm -rf "$HOMM3HD"
    printf "\n%s\n" "${AOK} HoMM3 HD installer was deleted."
    rm -rf "$HOMM3HOTA"
    printf "\n%s\n\n" "${AOK} HoMM3 HotA installer was deleted."
    # TODO: curl (+fix) & git & openssl - check lines ~290-310
    if [ "$(readlink -- "/usr/bin/curl")" = /usr/local/bin/curl ] && [ -f "/usr/bin/curl.old" ]; then
      sudo rm -rf "/usr/bin/curl"
      sudo mv -f "/usr/bin/curl.old" "/usr/bin/curl"
    else
      :
    fi
    if [ "$(readlink -- "/usr/bin/git")" = /usr/local/bin/git ] && [ -f "/usr/bin/git.old" ]; then
      sudo rm -rf "/usr/bin/git"
      sudo mv -f "/usr/bin/git.old" "/usr/bin/git"
    else
      :
    fi
    # Delete any leftover rice
    rm -rf "${HOME}/Downloads/OpenSSL_1_1_1j.tar.gz"
    rm -rf "${HOME}/Downloads/OpenSSL_1_1_1j.tar.gz"
    rm -rf "${HOME}/Downloads/curl-7.75.0.tar.gz"
    rm -rf "${HOME}/Downloads/curl-7.75.0"
    if [ -f "${ICONFOLDER}/HoMM3" ]; then
      rm -rf "${HOME}/Desktop/HoMM3.app"
    fi
    printf "%s\n" "${BOLD}HoMM3 and its dependencies have been uninstalled in $(elapsed_time 'end').${NC}"
    exit 0
  else
    printf "%s\n\n" "${AERROR} Aborting..." >&2
    exit 1
  fi
}

# Uninstall HoMM3 - Delete ${HOME}/.wine completely!
uninstall_homm3 () {
  SECONDS=0
  check_root
  printf "\a\n%s${AHR}\n" ""
  read -p "${RED}WARNING!${NC} The HoMM3 uninstaller will wipe your ${HOME}/.wine directory and therefore ${RED}HoMM3${NC} and every mods and ${RED}all your saved games${NC}! Enter '${RED}yes${NC}' to proceed if you are OK with the above. `echo $'\n> '`" </dev/tty
  if [[ $REPLY =~ ^yes$ ]]; then
    cd "${HOME}"
    rm -rf "${HOME}/.wine/"
    printf "\n%s\n" "${AOK} .wine directory was deleted."
    rm -rf "$HOMM3HD"
    printf "\n%s\n" "${AOK} HoMM3 HD installer was deleted."
    rm -rf "$HOMM3HOTA"
    printf "\n%s\n\n" "${AOK} HoMM3 HotA installer was deleted."
    printf "%s\n" "${BOLD}HoMM3 has been uninstalled in $(elapsed_time 'end').${NC}"
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
    printf "\a\n${AHR}\n%s\n%s\n%s\n%s\n%s\n" "${AINFO} Your OS is ${OSNAME}, version is ${OSVER}, type is ${OSTYPE:6}." "${AINFO} You might have to provide your admin password multiple times during " "the process, enter your gog.com password or download files, and allow " "or deny packages to install (check the help messages!)." "${AINFO} The whole install process ${BOLD}can take 10-60 minutes!${NC}"
    printf "%s${AHR}\n\n" ""
  else
    printf "\a\n%s\n%s\n%s\n\n" "${AERROR} Your OS is ${OSNAME}, version is ${OSVER}, type is ${OSTYPE:6}." "This installer is not suitable for macOS Catalina or Big Sur. Try this instead: https://github.com/anton-pavlov/homm3_docker" "We also do not support OS X Mavericks (or below) at the moment, try installing manually. Aborting..." >&2
    exit 1
  fi
}

# Curl insecure fix on.
curl_insecure_fix_on () {
  # curl --silent --time-cond "${HOME}/Downloads/cacert.pem" --output "${HOME}/Downloads/cacert.pem" https://curl.se/ca/cacert.pem
  # "cacert=${HOME}/Downloads/cacert.pem"
  if [ -f "${HOME}/.curlrc" ]; then
    mv -f "${HOME}/.curlrc" "${HOME}/.curlrc.old"
  fi
  printf "%s\n%s\n%s\n%s\n%s\n" "--fail" "--insecure" "--location" "--show-error" > "${HOME}/.curlrc"
  export HOMEBREW_CURLRC=1
}

# Curl insecure fix off.
curl_insecure_fix_off () {
  rm -rf "${HOME}/.curlrc"
  if [ -f "${HOME}/.curlrc.old" ]; then
    mv -f "${HOME}/.curlrc.old" "${HOME}/.curlrc"
  fi
}

# Ask for user input with a time limit. Fork of this: https://stackoverflow.com/a/56124134
function read_input_ttl {
  MESSAGE=$1
  COUNTDOWNSHORTMESSAGE=$2
  TIMEOUTREPLY=$3
  READTIMEOUT=$4
  printf "\a${MESSAGE}%s\n" ""
  for (( i=$READTIMEOUT; i>=0; i--)); do
    printf "\r${COUNTDOWNSHORTMESSAGE} ${i}s left > "
    read -s -n 1 -t 1 waitreadyn
    if [ $? -eq 0 ]; then
      break
    fi
  done
  ANSWER=""
  if [ -z $waitreadyn ]; then
    echo -e "\nNo input entered: Defaulting to '${RED}${TIMEOUTREPLY}${NC}'."
    export ANSWER="${TIMEOUTREPLY}"
  else
    echo -e "\n${waitreadyn}"
    export ANSWER="${waitreadyn}"
  fi
}

# Install Xcode. Opens a dialog prompt.
install_xs () {
  if xcode-select --print-path >/dev/null 2>&1 && xcode-select --version | grep -qsE "^xcode-select version 23[0-9]{2}.$" ; then
    if ((${OSTYPE:6} < 18)); then
      if [[ -f "/Library/Developer/CommandLineTools/usr/bin/git" && -f "/usr/include/iconv.h" ]]; then
        printf "%s\n\n" "${AOK} Xcode is installed."
      else
        xcode-select --install
        printf "\a\n%s\n\n" "${AINFO} Xcode is installing, check the dialog box. Return to this terminal when its done."
      fi
    else
      if [ -f "/Library/Developer/CommandLineTools/usr/bin/git" ]; then
        printf "%s\n\n" "${AOK} Xcode is installed."
      else
        xcode-select --install
        printf "\a\n%s\n\n" "${AINFO} Xcode is installing, check the dialog box. Return to this terminal when its done."
      fi
    fi
  else
    xcode-select --install
    printf "\a\n%s\n\n" "${AINFO} Xcode is installing, check the dialog box. Return to this terminal when its done."
  fi
}

# Install Git.
install_git () {
  SECONDS=0
  if brew list git; then
    printf "\n%s\n\n" "${AOK} Git is installed."
  else
    if ([ "${OSTYPE:6}" == "14" ]); then
      # Yosemite's built-in git is garbage, we have to use another solution.
      brew install --build-from-source git
      printf "\n%s\n\n" "${AOK} Git has been installed in $(elapsed_time)."
    elif ((${OSTYPE:6} >= 15 && ${OSTYPE:6} <= 17)); then
      export HOMEBREW_FORCE_BREWED_CURL=1
      export HOMEBREW_SYSTEM_CURL_TOO_OLD=1
      brew install --build-from-source git
      printf "\n%s\n\n" "${AOK} Git has been installed in $(elapsed_time)."
    else
      if brew ls --versions git >/dev/null; then
        brew upgrade git
	printf "\n%s\n\n" "${AOK} Git has been upgraded in $(elapsed_time)."
      else
        brew install git
        printf "\n%s\n\n" "${AOK} Git has been installed in $(elapsed_time)."
      fi
    fi
  fi
}

# Install Homebrew.
install_homebrew () {
  SECONDS=0
  if [[ $(command -v brew) == "" ]]; then
    if ([ "${OSTYPE:6}" == "14" ]); then
      # Tempfix for Xcode
      sleep 180
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
      # Give back modified folders to current user
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
      # Bypass Yosemite's curl bug: https://github.com/curl/curl/issues/998
      # We have to use the below hack because `brew link --force curl` isn't
      # working either and without that we can't bypass the SNI issue.
      #if [[ -L "/usr/bin/curl" && -f "/usr/bin/curl" ]]; then
      if [ "$(readlink -- "/usr/bin/curl")" = /usr/local/bin/curl ]; then
      	:
      else
      	sudo mv -f "/usr/bin/curl" "/usr/bin/curl.old"
      	sudo ln -s "/usr/local/bin/curl" "/usr/bin/curl"
      fi
      install_git
      if [ "$(readlink -- "/usr/bin/git")" = /usr/local/bin/git ]; then
        :
      else
        sudo mv -f /usr/bin/git /usr/bin/git.old
        sudo ln -s /usr/local/bin/git /usr/bin/git
      fi
      # Resolve the below Apple+git certificate error:
      # fatal: unable to access 'https://github.com/Homebrew/brew/':
      # SSL certificate problem: unable to get local issuer certificate
      # Failed during: git fetch --force origin
      git config --global http.https://github.com/.sslVerify false
      echo | /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      curl_insecure_fix_off
    else
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    printf "\n%s\n\n" "${AOK} Homebrew has been installed in $(elapsed_time)."
  else
    brew update
    printf "\n%s\n\n" "${AOK} Homebrew has been updated in $(elapsed_time)."
  fi
}

# Install XQuartz.
install_xquartz () {
  SECONDS=0
  curl_insecure_fix_on
  if brew list --cask xquartz; then
    printf "\n%s\n\n" "${AOK} XQuartz is installed."
  else
    brew install --cask xquartz
    printf "\n%s\n\n" "${AOK} XQuartz has been installed in $(elapsed_time)."
  fi
  curl_insecure_fix_off
}

# Install Wine.
install_wine () {
  SECONDS=0
  curl_insecure_fix_on
  if brew list --cask wine-stable; then
    printf "\n%s\n\n" "${AOK} Wine stable is installed."
  else
    if ((${OSTYPE:6} >= 14 && ${OSTYPE:6} <= 18)); then
      # Install Wine without Mono and Gecko.
      export WINEDLLOVERRIDES="mscoree,mshtml="
      brew install --cask wine-stable
      printf "\n%s\n\n" "${AOK} Wine stable has been installed in $(elapsed_time)."
    else
      if brew ls --versions wine >/dev/null; then
        printf "\n%s\n\n" "${AOK} Wine is installed."
      else
        export WINEDLLOVERRIDES="mscoree,mshtml="
        brew install wine
        printf "\n%s\n\n" "${AOK} Wine has been installed in $(elapsed_time)."
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

# Check HoMM3 installers.
check_h3_complete_installers () {
  if [ -f "${HOMM3CEXE}" ]; then
    printf "\n%s\n\n" "${AOK} HoMM3 Complete filepart #1 exists: ${HOMM3CEXE}"
    if [ -f "${HOMM3CBIN}" ]; then
      printf "%s\n\n" "${AOK} HoMM3 Complete filepart #2 exists: ${HOMM3CBIN}"
    else
      printf "%s\n%s\n\n" "${AERROR} HoMM3 Complete filepart #2 is missing: ${HOMM3CBIN}" "Download from gog.com. Aborting..." >&2
      exit 1
    fi
  else
    printf "%s\n%s\n\n" "${AERROR} HoMM3 Complete filepart #1 is missing: ${HOMM3CEXE}" "Download from gog.com. Aborting..." >&2
    exit 1
  fi
}

# Download HoMM3 installers.
dl_h3_complete_installers () {
  if [[ ( ${OSTYPE:6} -ge 14 && ${OSTYPE:6} -le 15 ) || ( ${OSTYPE:6} -ge 16 && ${OSTYPE:6} -le 17 && "${ANSWER}" -ne "b" ) ]]; then
    printf "\a%s\n" "${RED}Download${NC} HoMM3 Complete's offline backup game installers (~1 MB and ~0.9 GB) from your GoG games library: https://www.gog.com/account"
    read -p "Enter '${RED}yes${NC}' to proceed if you've already downloaded both the necessary installers to your '${RED}${HOME}/Downloads${NC}' folder (do not rename the files). `echo $'\n> '`"
    if [[ $REPLY =~ ^yes$ ]]; then
      check_h3_complete_installers
    else
      printf "%s\n\n" "${AERROR} Download the necessary files then restart the installer. Aborting..." >&2
      exit 1
    fi
  else
    check_h3_complete_installers
  fi
}

# Install Rust, Cargo and Wyvern, then download offline game installers from gog.com.
install_rust_cargo_wyvern () {
  SECONDS=0
  brew install rust
  printf "\n%s\n\n" "${AOK} Rust and Cargo have been installed in $(elapsed_time)."
  SECONDS=0
  cargo install wyvern
  printf "\n%s\n" "${AOK} Wyvern has been installed in $(elapsed_time)."
  SECONDS=0
  if grep -qsrHnE -- "Inserted by HoMM3 installer" "${HOME}/.bashrc" ; then
    :
  else
    printf "\n%s\n" 'export PATH="${HOME}/.cargo/bin:$PATH" # Inserted by HoMM3 installer.' >> "${HOME}/.bashrc"
    . "${HOME}/.bashrc"
  fi
  if [ -f "$WINEHOMM3C" ]; then
    printf "\n%s\n" "${AOK} HoMM3 Complete looks like installed, skipping gog.com login."
  elif [[ -f "${HOMM3CEXE}" && -f "${HOMM3CBIN}" ]]; then
    printf "\n%s\n" "${AOK} HoMM3 Complete fileparts do exist, skipping gog.com login."
  else
    printf "\a"
    read -p "Enter your '${RED}gog.com username${NC}' to proceed and download necessary HoMM3 files. `echo $'\n> '`"
    wyvern login --username "${REPLY}"
    # 1207658787 is the GoG ID of HoMM3 Complete
    wyvern down -w -i 1207658787 -o "${HOME}/Downloads/"
    printf "\n%s\n" "${AOK} HoMM3 Complete has been downloaded in $(elapsed_time)."
  fi
}

ask_user_before_installing_cargo () {
  curl_insecure_fix_on
  if ((${OSTYPE:6} >= 14 && ${OSTYPE:6} <= 15)); then
    # Rust and/or cargo and/or wyvern install fail, therefore we skip all.
    dl_h3_complete_installers
  elif ((${OSTYPE:6} >= 16 && ${OSTYPE:6} <= 17)); then
    # Building from source takes way too long, therefore we ask the user and set skip as default.
    read_input_ttl "On your Mac, building the dependencies to be able to download from gog.com takes 2-4 hours, meanwhile downloading in your browser takes less then 10 minutes. Therefore we are going to skip building the dependencies by default, and ask you to download the HoMM3 installer from gog.com. If you want to override this mechanism, type '${RED}b${NC} to ${RED}build${NC}' the dependencies." "Press 'b' to build, or any other key to skip (default)." "s" "60"
    if [ "${ANSWER}" == "b" ]; then
      install_rust_cargo_wyvern
      dl_h3_complete_installers
    else
      dl_h3_complete_installers
    fi
  else
    install_rust_cargo_wyvern
    dl_h3_complete_installers
  fi
  curl_insecure_fix_off
}

# Download and check HoMM3 HD and HotA.
check_h3_addons () {
  curl_insecure_fix_on
  if [ -f "$HOMM3HD" ]; then
    printf "%s\n\n" "${AOK} HoMM3 HD installer exists: $HOMM3HD"
    HOMM3EXPEXISTS=1
  else
    printf "%s\n" "${RED}Downloading${NC} HD edition (~15 MB) from https://sites.google.com/site/heroes3hd/eng/download"
    curl --progress-bar --output "$HOMM3HD" http://vm914332.had.yt/HoMM3_HD_Latest_setup.exe
  fi
  if [ -f "$HOMM3HOTA" ]; then
    printf "%s\n\n" "${AOK} HoMM3 HotA installer exists: $HOMM3HOTA"
    HOMM3EXPEXISTS=1
  else
    printf "%s\n" "${RED}Downloading${NC} HotA (~200 MB) from https://www.vault.acidcave.net/file.php?id=614"
    curl --progress-bar --output "$HOMM3HOTA" https://www.vault.acidcave.net/download.php?id=614
  fi
  curl_insecure_fix_off
  if [[ ! "${HOMM3EXPEXISTS}" == 1 ]]; then
    printf "\n%s\n\n" "${AOK} HoMM3 HD and HotA have been downloaded in $(elapsed_time)."
  fi
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

# Install HoMM3 HD & HotA without user interaction.
install_homm3hd_and_hota () {
  if ([ "${OSTYPE:6}" == "14" ]); then
    # HD mod and HotA is not working well on Yosemite, therefore we ask the user and set skip as default.
    read_input_ttl "On your Mac OS X Yosemite HD mod and HotA is buggy: the in-game mouse is missing or not shown in full size, therefore the gaming experience is crappy. So we do not install HD and HotA by default. If you want to override this mechanism, type '${RED}i${NC} to ${RED}install${NC}' them." "Press 'i' to install, or any other key to skip (default)." "s" "60"
    if [ "${ANSWER}" == "i" ]; then
      :
    else
      return 0
    fi
  fi
  if [ -f "$WINEHOMM3HD" ]; then
    printf "%s\n" "${AOK} HoMM3 HD installed."
  else
    printf "\n${AHR}\n%s\n${AHR}\n\n" "Installing HoMM3 HD into '${RED}${HOME}/.wine/drive_c/${FOLDERS}/${NC}' (Windows path: '${RED}C:\\${FOLDERS//\//\\}\\${NC}')."
    "${WINE}" $HOMM3HD /verysilent /supportDir="C:\GOG Games\HoMM 3 Complete\__support" /SUPPRESSMSGBOXES /NORESTART /DIR="C:\GOG Games\HoMM 3 Complete"
  fi
  if [ -f "$WINEHOMM3HOTA" ]; then
    printf "\n%s\n\n" "${AOK} HoMM3 HotA installed."
  else
    printf "\n${AHR}\n%s\n${AHR}\n\n" "Installing HotA into '${RED}${HOME}/.wine/drive_c/${FOLDERS}/${NC}' (Windows path: '${RED}C:\\${FOLDERS//\//\\}\\${NC}')."
    "${WINE}" $HOMM3HOTA /verysilent /supportDir="C:\GOG Games\HoMM 3 Complete\__support" /SUPPRESSMSGBOXES /NORESTART /DIR="C:\GOG Games\HoMM 3 Complete" /Language="English" /LANG="english"
  fi
}

# Update games. Not used at the moment.
update () {
  sleep 1
}

# Tweaking - Just once, line by line for easement.
tweak () {
  if [ ! -f "${HOME}/.wine/drive_c/${FOLDERS}/script.h3" ]; then
    sed -i.bak -e 's/<Misc.TournamentSaver> = 1/<Misc.TournamentSaver> = 0/g' "${HOTAINI}" && rm -rf "${HOTAINI}.bak"
    sed -i.bak -e 's/<Misc.BattleSaver> = 1/<Misc.BattleSaver> = 0/g' "${HOTAINI}" && rm -rf "${HOTAINI}.bak"
    sed -i.bak -e 's/<Main Game Full Screen> = 0/<Main Game Full Screen> = 1/g' "${HOTAINI}" && rm -rf "${HOTAINI}.bak"
    sed -i.bak -e 's/<Update.CheckAtStart> = 1/<Update.CheckAtStart> = 0/g' "${HOTAINI}" && rm -rf "${HOTAINI}.bak"
    #cp "${HOME}/.wine/drive_c/${FOLDERS}/h3hota.exe" "${HOME}/.wine/drive_c/${FOLDERS}/h3hotahd.exe"
    #edit the binary
    #cp the other .ini file too
    touch "${HOME}/.wine/drive_c/${FOLDERS}/script.h3"
  fi
}

# Create desktop icon or Dock shortcut.
generate_icon () {
  if [ -f "${ICONFOLDER}/HoMM3" ]; then
    printf "%s\n\n" "${AOK} HoMM3 icon is present on desktop."
  else
    mkdir -p "${ICONFOLDER}"
    if ([ "${OSTYPE:6}" == "14" ]); then
      cat <<EOT >> "${ICONFOLDER}/HoMM3"
#!/usr/bin/env bash
cd "${HOME}/.wine/drive_c/GOG Games/HoMM 3 Complete" && /usr/local/bin/wine "Heroes3.exe"
EOT
    else
      cat <<EOT >> "${ICONFOLDER}/HoMM3"
#!/usr/bin/env bash
cd "${HOME}/.wine/drive_c/GOG Games/HoMM 3 Complete" && /usr/local/bin/wine "HD_Launcher.exe"
EOT
    fi
    chmod 0700 "${ICONFOLDER}/HoMM3"
    printf "%s\n\n" "${AOK} HoMM3 icon has been created on desktop."
  fi
  # Delete the Wine-related useless icon.
  rm -rf "${HOME}/Desktop/Heroes of Might and Magic 3 Complete.desktop"
}

end_message () {
  printf "\a\n${AHR}\n%s\n\n" "${RED}How to run the game:${NC}"
  printf "%s\n\n" "${BOLD}Locate the desktop icon and click on it! :)${NC}"
  printf "%s\n\n" "${RED}How to run the game with command line:${NC}"
  printf "%s\n" "${RED}1.${NC} Run the following command in the Terminal (CMND+Space -> Terminal):"
  if ([ "${OSTYPE:6}" == "14" ]); then
    printf "%s\n" "${RED}cd \"${HOME}/.wine/drive_c/${FOLDERS}\" && wine Heroes3.exe${NC}"
    printf "%s\n" "Or if you chose to install HD mod & HotA too:"
  fi
  printf "%s\n" "${RED}cd \"${HOME}/.wine/drive_c/${FOLDERS}\" && wine HD_Launcher.exe${NC}"
  printf "%s\n" "${RED}2.${NC} Check for updates with '${RED}Update${NC}' button and install it if you find any!"
  printf "%s\n" "${RED}3.${NC} If the basic settings (resolution etc.) look OK, create the HD.exe with the '${RED}Create HD exe${NC}' button!"
  printf "%s\n%s\n" "${RED}4.${NC} Now you are ready to play! The above steps are not necessary in the future, just start the launcher" "in the Terminal with the above command (push up key for the last executed command) and hit '${RED}Play${NC}'!"
  printf "\n%s\n" "HoMM3 has been installed in $(elapsed_time 'end')."
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
ask_user_before_installing_cargo
check_h3_addons
install_homm3
install_homm3hd_and_hota
#update
tweak
generate_icon
end_message
set +e
