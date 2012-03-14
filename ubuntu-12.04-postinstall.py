#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# Mon script de post installation Ubuntu 12.04 LTS
#
# Syntax: # sudo ./ubuntupostinstall-12.04.sh
#
# Nicolargo (aka) Nicolas Hennion
# http://www.nicolargo.com
# Distributed under the GPL version 3 license
#

"""
Post installation script for Ubuntu 12.04 LTS
"""

import os, sys, platform, getopt, shutil, logging, getpass, ConfigParser

# Global variables
#-----------------------------------------------------------------------------

_VERSION="0.3a"
_DEBUG = 0
_LOG_FILE = "/tmp/ubuntu-12.04-postinstall.log"

# System commands
#-----------------------------------------------------------------------------

_APT_ADD = "add-apt-repository -y"
_APT_INSTALL = "apt-get -y install"
_APT_UPDATE = "apt-get -y update"
_APT_UPGRADE = "apt-get -y upgrade"
_APT_KEY = "apt-key adv --keyserver keyserver.ubuntu.com --recv-keys"
_WGET = "wget"

# Classes
#-----------------------------------------------------------------------------

class colors:
	RED = '\033[91m'
	GREEN = '\033[92m'
	BLUE = '\033[94m'
	ORANGE = '\033[93m'
	NO = '\033[0m'

	def disable(self):
		self.RED = ''
		self.GREEN = ''
		self.BLUE = ''
		self.ORANGE = ''
		self.NO = ''

# Functions
#-----------------------------------------------------------------------------

def init():
	"""
	Init the script
	"""
	# Globals variables
	global _VERSION
	global _DEBUG

	# Set the log configuration
	logging.basicConfig(
		filename=_LOG_FILE,
		level=logging.DEBUG,
		format='%(asctime)s %(levelname)s - %(message)s',
	 	datefmt='%d/%m/%Y %H:%M:%S',
	 )

def syntax():
	"""
	Print the script syntax
	"""
	print "TODO Syntax..."

def version():
	"""
	Print the script version
	"""
	sys.stdout.write ("Script version %s" % _VERSION)
	sys.stdout.write (" (running on %s %s)\n" % (platform.system() , platform.machine()))

def isroot():
	"""
	Check if the user is root
	Return TRUE if user is root
	"""
	return (os.geteuid() == 0)

def showexec(description, command, exitonerror = 0, presskey = 0, waitmessage = ""):
	"""
	Exec a system command with a pretty status display (Running / Ok / Warning / Error)
	By default (exitcode=0), the function did not exit if the command failed
	"""

	if _DEBUG: 
		logging.debug ("%s" % description)
		logging.debug ("%s" % command)

	# Wait message
	if (waitmessage == ""):
		waitmessage = description

	# Manage very long description
	if (len(waitmessage) > 65):
		waitmessage = waitmessage[0:65] + "..."
	if (len(description) > 65):
		description = description[0:65] + "..."
		
	# Display the command
	if (presskey == 1):
		status = "[ ENTER ]"
	else:	
		status = "[Running]"
	statuscolor = colors.BLUE
	sys.stdout.write (colors.NO + "%s" % waitmessage + statuscolor + "%s" % status.rjust(79-len(waitmessage)) + colors.NO)
	sys.stdout.flush()

	# Wait keypressed (optionnal)
	if (presskey == 1):
		try:
			input = raw_input
		except: 
			pass
		raw_input()

	# Run the command
	returncode = os.system ("/bin/sh -c \"%s\" >> /dev/null 2>&1" % command)
	
	# Display the result
	if returncode == 0:
		status = "[  OK   ]"
		statuscolor = colors.GREEN
	else:
		if exitonerror == 0:
			status = "[Warning]"
			statuscolor = colors.ORANGE
		else:
			status = "[ Error ]"
			statuscolor = colors.RED

	sys.stdout.write (colors.NO + "\r%s" % description + statuscolor + "%s\n" % status.rjust(79-len(description)) + colors.NO)

	if _DEBUG: 
		logging.debug ("Returncode = %d" % returncode)

	# Stop the program if returncode and exitonerror != 0
	if ((returncode != 0) & (exitonerror != 0)):
		if _DEBUG: 
			logging.debug ("Forced to quit")
		exit(exitonerror)

def getpassword(description = ""):
	"""
	Read password (with confirmation)
	"""
	if (description != ""): 
		sys.stdout.write ("%s\n" % description)
		
	password1 = getpass.getpass("Password: ");
	password2 = getpass.getpass("Password (confirm): ");

	if (password1 == password2):
		return password1
	else:
		sys.stdout.write (colors.ORANGE + "[Warning] Password did not match, please try again" + colors.NO + "\n")
		return getpassword()

def getstring(message = "Enter a value: "):
	"""
	Ask user to enter a value
	"""
	try:
		input = raw_input
	except: 
		pass
	return raw_input(message)

def waitenterpressed(message = "Press ENTER to continue..."):
	"""
	Wait until ENTER is pressed
	"""
	try:
		input = raw_input
	except: 
		pass
	raw_input(message)
	return 0
		
def main(argv):
	"""
	Main function
	"""
	try:
		opts, args = getopt.getopt(argv, "c:hvd", ["config", "help", "version", "debug"])
	except getopt.GetoptError:
		syntax()
		exit(2)

	config_file = ""
	for opt, arg in opts:
		if opt in ("-c", "--config"):
			config_file = arg
		elif opt in ("-h", "--help"):
			syntax()
			exit()
		elif opt in ('-v', "--version"):
			version()
			exit()
		elif opt in ('-d', "--debug"):
			global _DEBUG
			_DEBUG = 1

	# Are your root ?
	if (not isroot()):
		showexec ("Script should be run as root", "tpastroot", exitonerror = 1)
		
	# Is it Precise Pangolin ?
	_UBUNTU_VERSION = platform.linux_distribution()[2]
	if (_UBUNTU_VERSION != "precise"):
		showexec ("Script only for Ubuntu 12.04", "tpassousprecise", exitonerror = 1)
	
	# Read the configuration file
	if (config_file == ""):
		config_file = "/tmp/ubuntu-12.04-postinstall.cfg"
		showexec ("Download the default configuration file", _WGET+" -O "+config_file+" https://raw.github.com/nicolargo/ubuntupostinstall/master/ubuntu-12.04-postinstall.cfg" )		
	config = ConfigParser.RawConfigParser()
	config.read(config_file)

	if (config.has_section("gnome3") and config.has_section("unity")):
		showexec ("Can use both Gnome 3 and Unity, please change your .cfg file", "gnome3etunitygrosboulet", exitonerror = 1)		

	# Parse and exec pre-actions
	for action_name, action_cmd in config.items("preactions"):
		showexec ("Execute preaction "+action_name.lstrip("action_"), action_cmd)
	
	# Parse and install repositories
	pkg_list_others = {}
	for item_type, item_value in config.items("repos"):
		if (item_type.startswith("ppa_")):
			showexec ("Install repository "+item_type.lstrip("ppa_"), _APT_ADD+" "+item_value)
		elif (item_type.startswith("url_")):
			showexec ("Install repository "+item_type.lstrip("url_"), _APT_ADD+" \"deb "+item_value+"\"")
		elif (item_type.startswith("key_")):
			showexec ("Install key for the "+item_type.lstrip("key_")+" repository", _APT_KEY+item_value)
		elif (item_type.startswith("pkg_")):
			pkg_list_others[item_type] = item_value

	# Update repos
	showexec ("Update repositories", _APT_UPDATE)
	
	# Upgrade system
	showexec ("System upgrade (please be patient...)", _APT_UPGRADE)

	# Parse and install packages
	for pkg_type, pkg_list in config.items("packages"):
		showexec ("Install packages "+pkg_type, _APT_INSTALL+" "+pkg_list)
	
	# Install packages related to repositories
	#~ print pkg_list_others
	for pkg in pkg_list_others.keys():
		showexec ("Install packages "+pkg, _APT_INSTALL+" "+pkg_list_others[pkg])

	# Allow user to read DVD (CSS)
	showexec ("DVDs CSS encryption reader", "sh /usr/share/doc/libdvdread4/install-css.sh")

	# Download and install dotfiles: vimrc, prompt...
	if (config.has_section("dotfiles")):
		# Create the bashrc.d subfolder
		showexec ("Create the ~/.bashrc.d subfolder", "mkdir -p $HOME/.bashrc.d")
		if (config.has_option("dotfiles", "bashrc")):
			showexec ("Install bash main configuration file", _WGET+" -O $HOME/.bashrc "+config.get("dotfiles", "bashrc"))
		if (config.has_option("dotfiles", "bashrc_prompt")):
			showexec ("Install bash prompt configuration file", _WGET+" -O $HOME/.bashrc.d/bashrc_prompt "+config.get("dotfiles", "bashrc_prompt"))
		if (config.has_option("dotfiles", "bashrc_aliases")):
			showexec ("Install bash aliases configuration file", _WGET+" -O $HOME/.bashrc.d/bashrc_aliases "+config.get("dotfiles", "bashrc_aliases"))
		# Update the shell
		showexec ("Reload the Bash configuration file", "source $HOME/.bashrc")
		# Vim
		if (config.has_option("dotfiles", "vimrc")):
			showexec ("Install the Vim configuration file", _WGET+" -O $HOME/.vimrc "+config.get("dotfiles", "vimrc"))

	# Gnome 3 configuration
	if (config.has_section("gnome3")):
		# Set the default theme
		if (config.has_option("gnome3", "theme")):
			showexec ("Set the default Gnome Shell theme to "+config.get("gnome3", "theme"), "gsettings set org.gnome.desktop.interface gtk-theme "+config.get("gnome3", "theme"))
		# Set the default icons
		if (config.has_option("gnome3", "icons")):
			showexec ("Set the default Gnome Shell icons to "+config.get("gnome3", "icons"), "gsettings set org.gnome.desktop.interface icon-theme "+config.get("gnome3", "icons"))
		# Set the default cursors
		if (config.has_option("gnome3", "cursors")):
			showexec ("Set the default Gnome Shell cursors to "+config.get("gnome3", "cursors"), "gsettings set org.gnome.desktop.interface cursor-theme "+config.get("gnome3", "cursors"))
		# Download and install the default Conky configuration
		if (config.has_option("gnome3", "conky")):
			showexec ("Install the Conky configuration file", _WGET+" -O $HOME/.conkyrc "+config.get("gnome3", "conky"))
		# Get the minimize/maximize button and ALT-F2 shortcut back
		showexec ("Get the minimize and maximize button back in Gnome Shell", "gconftool-2 -s -t string /desktop/gnome/shell/windows/button_layout \":minimize,maximize,close\"")
		showexec ("Get ALT-F2 back to me", "gconftool-2 --recursive-unset /apps/metacity/global_keybindings")
		# Gnome Shell is the default UI
		showexec ("Gnome Shell is now the default shell", "/usr/lib/lightdm/lightdm-set-defaults -s gnome-shell")

	# Unity configuration
	if (config.has_section("unity")):
		# Set the default theme
		if (config.has_option("unity", "theme")):
			showexec ("Set the default Unity theme to "+config.get("unity", "theme"), "gsettings set org.gnome.desktop.interface gtk-theme "+config.get("unity", "theme"))
		# Set the default icons
		if (config.has_option("unity", "icons")):
			showexec ("Set the default Unity icons to "+config.get("unity", "icons"), "gsettings set org.gnome.desktop.interface icon-theme "+config.get("unity", "icons"))
		# Set the default cursors
		if (config.has_option("unity", "cursors")):
			showexec ("Set the default Unity cursors to "+config.get("unity", "cursors"), "gsettings set org.gnome.desktop.interface cursor-theme "+config.get("unity", "cursors"))
		# Unity is the default UI
		showexec ("Unity is now the default shell", "/usr/lib/lightdm/lightdm-set-defaults -s unity-3d")

	# Parse and exec post-actions
	for action_name, action_cmd in config.items("postactions"):
		showexec ("Execute postaction "+action_name.lstrip("action_"), action_cmd)

	# End of the script
	print("---")
	print("End of the script.")
	print(" - Cfg file: "+config_file)
	print(" - Log file: "+_LOG_FILE)
	print("")
	print("Please restart your session to complete.")
	print("---")

# Main program
#-----------------------------------------------------------------------------

if __name__ == "__main__":
	init()
	main(sys.argv[1:])
	exit()
