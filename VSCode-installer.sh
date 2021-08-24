#!/bin/bash

# Set Default Installation Variables
OPERATION=help
INSTALL_STYLE=home

# Define Functions
generate_launcher() {
	echo "[Desktop Entry]" > /tmp/code.desktop
	echo "Name=Visual Studio Code" >> /tmp/code.desktop
	echo "Comment=Code Editing. Redefined." >> /tmp/code.desktop
	echo "Exec=code --unity-launch %F" >> /tmp/code.desktop
	echo "Icon=com.visualstudio.code" >> /tmp/code.desktop
	echo "Type=Application" >> /tmp/code.desktop
	echo "StartupNotify=false" >> /tmp/code.desktop
	echo "StartupWMClass=Code" >> /tmp/code.desktop
	echo "Categories=Utility;TextEditor;Development;IDE;" >> /tmp/code.desktop
	echo "MimeType=text/plain;inode/directory;application/x-code-workspace;" >> /tmp/code.desktop
	echo "Actions=new-empty-window;" >> /tmp/code.desktop
	echo "Keywords=vscode;" >> /tmp/code.desktop
	echo "" >> /tmp/code.desktop
	echo "[Desktop Action new-empty-window]" >> /tmp/code.desktop
	echo "Name=New Empty Window" >> /tmp/code.desktop
	echo "Exec=code --new-window %F" >> /tmp/code.desktop
	echo "Icon=com.visualstudio.code" >> /tmp/code.desktop
}

install() {
	echo "Installing VSCode to $INSTALL_STYLE"

	# Keep temporary files in /tmp
	cd /tmp

	# Remove any old downloads
	rm code-stable-x64-*.tar.gz
	rm -rf VSCode-linux-x64

	# Download and extract VSCode
	curl -OJL https://code.visualstudio.com/sha/download\?build\=stable\&os\=linux-x64
	tar xf code-stable-x64-*.tar.gz

	# Generate Launcher file
	generate_launcher

	# Install VSCode to proper directory
	if [ "${INSTALL_STYLE}" = "home" ]; then
		# Make sure install directory exists
		if [ ! -d "~/.local/share" ]; then
			mkdir -p ~/.local/share
		fi

		# Move files
		mv VSCode-linux-x64 ~/.local/share/VSCode

		# Make sure bin directory exists
		if [ ! -d "~/.local/bin" ]; then
			mkdir -p ~/.local/bin
		fi

		# Symlink binary
		ln -s ~/.local/share/VSCode/bin/code ~/.local/bin/

		# Make sure launcher directory exists
		if [ ! -d "~/.local/share/applications" ]; then
			mkdir -p ~/.local/share/applications
		fi

		# Move launcher file
		mv /tmp/code.desktop ~/.local/share/applications/code.desktop

		# Update launcher file
		sed -i 's/Exec=code/Exec=~\/.local\/bin\/code/g' ~/.local/share/applications/code.desktop
		
		# Update desktop database
		update-desktop-database ~/.local/share/applications

	elif [ "${INSTALL_STYLE}" = "root" ]; then
		# Make sure install directory exists
		if [ ! -d "/opt" ]; then
			mkdir -p /opt
		fi

		# Move files
		mv VSCode-linux-x64 /opt/VSCode

		# Make sure bin directory exists
		if [ ! -d "/usr/local/bin" ]; then
			mkdir -p /usr/local/bin
		fi

		# Symlink binary
		ln -s /opt/VSCode/bin/code /usr/local/bin/code

		# Make sure launcher directory exists
		if [ ! -d "/usr/local/share/applications" ]; then
			mkdir -p /usr/local/share/applications
		fi

		# Move launcher file
		mv /tmp/code.desktop /usr/local/share/applications/code.desktop

		# Update the launcher file
		sed -i 's/Exec=code/Exec=\/usr\/local\/bin\/code/g' /usr/local/share/applications/code.desktop

		# Update desktop database
		update-desktop-database

	else
		echo "Invalid INSTALL_STYLE: $INSTALL_STYLE"
		exit 1
	fi
}

uninstall() {
	echo "Uninstalling currently installed version from $INSTALL_STYLE"

	# Uninstall VSCode from proper directory
	if [ "${INSTALL_STYLE}" = "home" ]; then
		rm ~/.local/bin/code
		rm ~/.local/share/applications/code.desktop
		rm -rf ~/.local/share/VSCode
		update-desktop-database ~/.local/share/applications

	elif [ "${INSTALL_STYLE}" = "root" ]; then
		rm /usr/local/bin/code
		rm /usr/local/share/applications/code.desktop
		rm -rf /opt/VSCode
		update-desktop-database

	else
		echo "Invalid INSTALL_STYLE: $INSTALL_STYLE"
		exit 1
	fi
}

# Parse Flages
while getopts o:s flag
do
	case "${flag}" in
		o) OPERATION=${OPTARG};;
		s) INSTALL_STYLE=${OPTARG};;
		*) OPERATION=help;;
	esac
done

# Perform Operations
if [ "${OPERATION}" = "install" ]; then
	install

elif [ "${OPERATION}" = "uninstall" ]; then
	uninstall

elif [ "${OPERATION}" = "upgrade" ]; then
	echo "This will uninstall your current version and install the latest version"
	uninstall
	install

else
	echo "Usage: VSCode-install.sh -o OPERATION -s INSTALL_STYLE"
	echo
	echo "Providing an OPERATION is mandatory"
	echo "Available OPERATION Options:"
	echo "* install"
	echo "* uninstall"
	echo "* upgrade"
	echo
	echo "Providing an INSTALL_STYLE is optional"
	echo "Available INSTALL_STYLE options"
	echo "* home"
	echo "* root"
	echo "The default option is home"
fi
