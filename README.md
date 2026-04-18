# 🛠️ Sleeper Builder

Sleeper Builder is an automated Android ROM build script (AOSP/LineageOS-based) designed to run with minimal user interaction.

You configure everything at the beginning, and the script handles the entire process automatically:

environment setup
repo initialization
double sync
manifest handling
Samsung-specific fixes
ROM signing
build execution

coded by @miguelbarretoo

# ⚙️ Features
⚡ Automatic environment setup

🔄 Double repo sync (more reliable)


📦 Support to the most recent Odessa (moto g9 plus) trees manifests or custom ones

🔐 Automatic ROM signing

📱 Samsung device fixes (hardware + NFC)

🧠 CI-like execution (no pauses)

🛠️ Fully configurable at startup

# 🚀 Usage
1. Download the script

       git clone https://github.com/NexusBR-odessa/shimi_lala.git
       cd shimi_lala

Or simply download the .sh file.

2. Make it executable

       chmod +x sleeper.sh

3. Run the script

       ./builder.sh

4. Configure everything at startup

======================================

When you run the script, it will ask:

If you want to install all the dependencies

Main ROM manifest URL and branch

Your GitHub name and email

Working directory

Whether to use Odessa or custom manifest (script optmized for moto g9 plus builds with the most recent trees manifests)

Whether the device is Samsung (it will apply a fix to sync hardware/samsung/nfc)

Whether to sign the ROM

Whether to start the build automatically

lunch command

build command

After that, the script runs fully unattended.

# 🔄 Script Flow
Initial configuration        
                           ↓       
Environment setup        
       ↓       
repo init        
       ↓       
Manifest clone        
       ↓       
repo sync (1/2)        
       ↓       
repo sync (2/2)        
       ↓       
Samsung fix (if enabled)        
       ↓       
Signing (optional)        
       ↓       
Build (optional)

# 📱 Samsung Support

If enabled, the script automatically:

Replaces hardware/samsung
Syncs NFC components

This fixes common issues when building for Samsung devices.

# 🔐 ROM Signing

If enabled, the script:

Clones the crDroid signing script
Automatically sets up the signing environment
Runs it without manual interaction (auto ENTER input)

# 🧠 Sleeper Mode

The name “Sleeper” comes from its behavior:

Configure once → let it run everything automatically.

Perfect for:

VPS environments

Automated builds

CI workflows
