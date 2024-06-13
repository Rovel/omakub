# Be fancy
source ~/.local/share/omakub/ascii.sh

# Exit immediately if a command exits with a non-zero status
set -e

# Needed for all installers
sudo apt update -y
sudo apt install -y curl git unzip

# Ensure computer doesn't go to sleep or lock while installing
gsettings set org.gnome.desktop.screensaver lock-enabled false
gsettings set org.gnome.desktop.session idle-delay 0

# Initialize an array to hold the names of the scripts to skip
declare -a skip_scripts

# Initialize a variable to indicate whether to source the extra scripts
extras=false

# Parse command-line options only if arguments are provided
if [ "$#" -gt 0 ]; then
  while (( "$#" )); do
    case "$1" in
      -s|--skip)
        # Add the argument of the --skip option to the array
        skip_scripts+=("$2")
        shift 2
        ;;
      --extras)
        # Set the extras variable to true
        extras=true
        shift
        ;;
      --)
        shift
        break
        ;;
      -*|--*=)
        echo "Error: Unsupported flag $1" >&2
        exit 1
        ;;
    esac
  done
fi

# Function to source scripts in a directory
source_scripts() {
  for script in $1/*.sh; do
    # Extract the script name from the path
    script_name=$(basename $script)

    # Check if the current script is in the list of scripts to skip
    if [[ " ${skip_scripts[@]} " =~ " ${script_name} " ]]; then
      echo "Skipping ${script_name}"
      continue
    fi

    # Source the script
    source $script
  done
}

# Source the regular scripts
source_scripts ~/.local/share/omakub/install

# If the --extras flag was provided, source the extra scripts
if $extras; then
  source_scripts ~/.local/share/omakub/install/extras
fi

# Upgrade everything that might ask for a reboot last
sudo apt upgrade -y

# Revert to normal idle and lock settings
gsettings set org.gnome.desktop.screensaver lock-enabled true
gsettings set org.gnome.desktop.session idle-delay 300

# Logout to pickup changes
gum confirm "Ready to logout for all settings to take effect?" && gnome-session-quit --logout --no-prompt
