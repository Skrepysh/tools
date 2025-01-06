#!/bin/bash

# By skrepysh.dll <3

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

# Check OS and set release variable
if [[ -f /etc/os-release ]]; then
    source /etc/os-release
    release=$ID
elif [[ -f /usr/lib/os-release ]]; then
    source /usr/lib/os-release
    release=$ID
else
    echo "Failed to check the system OS, please contact the author!" >&2
    rm -- "$0"
    exit 1
fi

function LOGD() {
    echo -e "${yellow}[DEG] $* ${plain}"
}

function LOGE() {
    echo -e "${red}[ERR] $* ${plain}"
}

function LOGI() {
    echo -e "${green}[INF] $* ${plain}"
}

function confirm() {
    if [[ $# -gt 1 ]]; then
        echo && read -p "$1 [Default $2]: " temp
        if [[ "${temp}" == "" ]]; then
            temp=$2
        fi
    else
        read -p "$1 [y/n]: " temp
    fi
    if [[ "${temp}" == "y" || "${temp}" == "Y" ]]; then
        return 0
    else
        return 1
    fi
}

# check root
[[ $EUID -ne 0 ]] && LOGE "ERROR: You must be root to run this script! \n" && rm -- "$0" && exit 1

echo "The OS release is: $release"

os_version=""
os_version=$(grep "^VERSION_ID" /etc/os-release | cut -d '=' -f2 | tr -d '"' | tr -d '.')
already_installed=0

if [[ "${release}" == "centos" ]]; then
    if [[ ${os_version} -lt 8 ]]; then
        echo -e "${red} Please use CentOS 8 or higher ${plain}\n" && rm -- "$0" && exit 1
    fi
    if [ "$(command -v warp-cli)" ]; then
        already_installed=1
	else
		LOGI "Adding cloudflare warp repo"
	    curl -fsSl https://pkg.cloudflareclient.com/cloudflare-warp-ascii.repo | tee /etc/yum.repos.d/cloudflare-warp.repo >> /dev/null 2>&1
	    LOGI "Updating repos"
	    yum update >> /dev/null 2>&1
	    LOGI "Installing warp-cli"
	    yum -y install cloudflare-warp >> /dev/null 2>&1
	fi
elif [[ "${release}" == "ubuntu" ]]; then
    if [[ ${os_version} -lt 2004 ]]; then
        echo -e "${red} Please use Ubuntu 20 or higher version!${plain}\n" && rm -- "$0" && exit 1
    fi
    if [ "$(command -v warp-cli)" ]; then
        already_installed=1
	else
		LOGI "Adding cloudflare warp key and repo"
	   	curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg >> /dev/null 2>&1
	   	echo "deb [signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/cloudflare-client.list >> /dev/null 2>&1
	    LOGI "Updating repos"
	    apt-get update >> /dev/null 2>&1
	    LOGI "Installing warp-cli"
	    apt-get -y install cloudflare-warp >> /dev/null 2>&1
	fi
elif [[ "${release}" == "debian" ]]; then
    if [[ ${os_version} -lt 10 ]]; then
        echo -e "${red} Please use Debian 11 or higher ${plain}\n" && rm -- "$0" && exit 1
    fi
    if [ "$(command -v warp-cli)" ]; then
        already_installed=1
	else
		LOGI "Updating repos"
		apt update >> /dev/null 2>&1
		LOGI "Installing gpg"
		apt -y install gpg >> /dev/null 2>&1
		LOGI "Adding cloudflare warp key and repo"
	   	curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | sudo gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg >> /dev/null 2>&1
	   	echo "deb [signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/cloudflare-client.list >> /dev/null 2>&1
	    LOGI "Updating repos"
	    apt-get update >> /dev/null 2>&1
	    LOGI "Installing warp-cli"
	    apt-get -y install cloudflare-warp >> /dev/null 2>&1
	fi
else
    echo -e "${red}Your operating system is not supported by this script.${plain}\n"
    echo "Please ensure you are using one of the following supported operating systems:"
    echo "- Ubuntu 20.04+"
    echo "- Debian 10+"
    echo "- CentOS 8+"
    rm -- "$0"
    exit 1
fi

if [[ "${already_installed}" == 1 ]]; then
	LOGD "warp-cli is already installed"
	confirm "Do you want to continue warp setting up? This will delete your existing warp registration (y/n)" "n"
	if [[ $? == 0 ]]; then
		continue_setup=1
  		echo -n -e "\n${green}Stopping warp-cli: ${plain}"
    		warp-cli --accept-tos disconnect
		echo -n -e "${green}Deleting current registration: ${plain}"
		warp-cli --accept-tos registration delete
	else 
		echo -e "\n${green}[INF] Exiting... ${plain}"
  		rm -- "$0"
		exit 1
	fi
else 
	continue_setup=1
fi

if [[ "${already_installed}" == 0 ]] || [[ "${continue_setup}" == 1 ]]; then
	LOGI "Checking if warp-cli is installed"
	if [ $(command -v warp-cli) ]; then
        LOGI "Check is OK, setting up"
        echo -n -e "${green}Registration: ${plain}"
        warp-cli --accept-tos registration new
        echo -n -e "${green}Setting mode proxy: ${plain}"
		warp-cli --accept-tos mode proxy
		echo -n -e "${green}Setting proxy port to 30000: ${plain}"
		warp-cli --accept-tos proxy port 30000
		echo && echo -n -e "${yellow}Enter WARP-Plus key (leave blank if you don't have a key): ${plain}" && read warp_key
	    if [[ -z "${warp_key}" ]]; then
	        echo -e "\n${green}[INF] OK, пон ${plain}"
	    else
	    	echo -n -e "\n${green}Setting WARP-Plus key: ${plain}"
	    	warp-cli --accept-tos registration license $warp_key
	    fi
	    echo -n -e "${green}Starting warp-cli: ${plain}"
		warp-cli --accept-tos connect
		LOGI "warp-cli was set up successfully!"
		LOGI "You can access socks proxy on 127.0.0.1:30000"
		LOGE "YOU DON'T NEED TO OPEN 30000 PORT!!!"
	else
		LOGE "warp-cli can't be found. Looks like, the installation was unsuccessful"
  		rm -- "$0"
		exit 1 
	fi
fi

rm -- "$0"
