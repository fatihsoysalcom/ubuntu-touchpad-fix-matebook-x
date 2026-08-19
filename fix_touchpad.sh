#!/bin/bash

# This script attempts to provide a common solution for touchpad freezing issues on Huawei Matebook X with Ubuntu.
# The issue often stems from kernel module conflicts or incorrect driver loading.
# This script focuses on blacklisting problematic modules and ensuring the correct ones are loaded.

# Define modules to blacklist (common culprits for touchpad issues)
BLACKLIST_MODULES=("hid_multitouch" "i2c_hid")

# Define modules to ensure are loaded (or reloaded)
LOAD_MODULES=("hid_generic" "i2c_hid_acpi")

# Function to check if a module is loaded
module_loaded() {
    lsmod | grep -q "^$1 "
}

# Function to blacklist a module
blacklist_module() {
    local module="$1"
    if ! grep -q "blacklist $module" /etc/modprobe.d/blacklist-matebook-touchpad.conf 2>/dev/null;
    then
        echo "Blacklisting module: $module"
        echo "blacklist $module" | sudo tee -a /etc/modprobe.d/blacklist-matebook-touchpad.conf > /dev/null
    else
        echo "Module $module is already blacklisted."
    fi
}

# Function to load a module
load_module() {
    local module="$1"
    if ! module_loaded "$module";
    then
        echo "Loading module: $module"
        sudo modprobe "$module"
    else
        echo "Module $module is already loaded."
    fi
}

echo "Starting Matebook X Ubuntu Touchpad Fix Script..."

# Ensure the blacklist configuration file exists
sudo touch /etc/modprobe.d/blacklist-matebook-touchpad.conf

# Blacklist problematic modules
for module in "${BLACKLIST_MODULES[@]}"; do
    blacklist_module "$module"
done

# Reload initramfs to apply blacklist changes
echo "Updating initramfs..."
sudo update-initramfs -u

# Load necessary modules (may require a reboot for full effect)
for module in "${LOAD_MODULES[@]}"; do
    load_module "$module"
done

echo "Touchpad fix script finished."
echo "Please REBOOT your system for changes to take full effect."
