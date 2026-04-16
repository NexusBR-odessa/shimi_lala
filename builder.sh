#!/bin/bash

echo "===== Sleeper Builder Script by Miguel Barreto ====="
echo "===== Initial Configuration ====="

# ===== INPUT DO USUÁRIO =====

read -p "Are you in ServerHive? (y/n): " input_server
[[ "$input_server" =~ ^[Yy]$ ]] && IN_SERVERHIVE=true || IN_SERVERHIVE=false

# Repo
while true; do
    read -p "Enter ROM manifest URL: " REPO_URL
    [[ -n "$REPO_URL" ]] && break || echo "URL cannot be empty."
done

while true; do
    read -p "Enter branch: " REPO_BRANCH
    [[ -n "$REPO_BRANCH" ]] && break || echo "Branch cannot be empty."
done

# Git
while true; do
    read -p "Enter GitHub username: " GIT_NAME
    [[ -n "$GIT_NAME" ]] && break || echo "Cannot be empty."
done

while true; do
    read -p "Enter GitHub email: " GIT_EMAIL
    [[ -n "$GIT_EMAIL" ]] && break || echo "Cannot be empty."
done

# Diretório
read -p "Enter working directory (default: ~/SleeperBuilder): " WORK_DIR
WORK_DIR=${WORK_DIR:-~/SleeperBuilder}
WORK_DIR="${WORK_DIR/#\~/$HOME}"   # resolve ~
WORK_DIR="${WORK_DIR%/}"            # remove trailing slash

# Manifest
read -p "Use Odessa trees manifest? (y/n): " input_odessa
if [[ "$input_odessa" =~ ^[Yy]$ ]]; then
    USE_ODESSA=true
else
    USE_ODESSA=false

    while true; do
        read -p "Enter custom trees manifest URL: " MANIFEST_URL
        [[ -n "$MANIFEST_URL" ]] && break || echo "URL cannot be empty."
    done

    read -p "Enter manifest branch (default: main): " MANIFEST_BRANCH
    MANIFEST_BRANCH=${MANIFEST_BRANCH:-main}
fi

# Samsung NFC fix
read -p "Is your device Samsung? (y/n): " input_samsung
[[ "$input_samsung" =~ ^[Yy]$ ]] && IS_SAMSUNG=true || IS_SAMSUNG=false

# Signing
read -p "Do you want to sign the ROM? (y/n): " input_sign
[[ "$input_sign" =~ ^[Yy]$ ]] && SIGN_ROM=true || SIGN_ROM=false

# Build
read -p "Do you want to start the build? (y/n): " input_build
if [[ "$input_build" =~ ^[Yy]$ ]]; then
    START_BUILD=true

    while true; do
        read -p "Enter lunch command: " LUNCH_CMD
        [[ -n "$LUNCH_CMD" ]] && break || echo "Cannot be empty."
    done

    while true; do
        read -p "Enter build command: " BUILD_CMD
        [[ -n "$BUILD_CMD" ]] && break || echo "Cannot be empty."
    done
else
    START_BUILD=false
fi

echo ""
echo "===== Starting automated process ====="

# ===== EXECUÇÃO AUTOMÁTICA =====

# Dependências
if [[ "$IN_SERVERHIVE" == false ]]; then
    echo "===== Updating and installing dependencies ====="
    sudo apt update
    sudo apt install -y bc bison build-essential ccache curl flex g++-multilib gcc-multilib git git-lfs gnupg gperf imagemagick lib32ncurses5-dev lib32readline-dev lib32z1-dev liblz4-tool libncurses5 libncurses5-dev libsdl1.2-dev libssl-dev libwxgtk3.0-gtk3-dev libxml2 libxml2-utils lzop pngcrush rsync schedtool squashfs-tools xsltproc zip zlib1g-dev
else
    echo "===== Skipping dependencies ====="
fi

# Repo tool
mkdir -p ~/bin
export PATH=~/bin:$PATH

curl -s https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod a+x ~/bin/repo

# Git config
echo "===== Configuring Git ====="
git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"

# Diretório
mkdir -p "$WORK_DIR"
cd "$WORK_DIR" || exit

# Init repo
echo "===== Initializing repo ====="
repo init -u "$REPO_URL" -b "$REPO_BRANCH" --git-lfs

# Manifest
echo "===== Setting up manifest ====="

if [[ "$USE_ODESSA" == true ]]; then
    git clone https://github.com/NexusBR-odessa/local_manifests_odessa.git -b 16.0-QPR2 .repo/local_manifests
else
    git clone "$MANIFEST_URL" -b "$MANIFEST_BRANCH" .repo/local_manifests
fi

# Sync x2
echo "===== Syncing sources (1/2) ====="
repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags

echo "===== Syncing sources (2/2) ====="
repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags

# Samsung fix
if [[ "$IS_SAMSUNG" == true ]]; then
    echo "===== Applying Samsung hardware fix ====="

    rm -rf hardware/samsung

    git clone https://github.com/LineageOS/android_hardware_samsung hardware/samsung

    echo "===== Syncing Samsung NFC ====="
    repo sync -f hardware/samsung/nfc
else
    echo "===== Skipping Samsung-specific setup ====="
fi

# Signing
if [[ "$SIGN_ROM" == true ]]; then
    echo "===== Setting up signing ====="

    # Cria uma pasta temporária fora do WORK_DIR para clonar
    SIGN_SCRIPT_DIR="$(dirname "$WORK_DIR")/crDroid-signed-script-temp"
    mkdir -p "$SIGN_SCRIPT_DIR"
    
    cd "$SIGN_SCRIPT_DIR" || exit
    git clone https://github.com/crdroidandroid/crDroid-build-signed-script.git

    # Move os arquivos para dentro do WORK_DIR
    mv crDroid-build-signed-script/* "$WORK_DIR"/ 2>/dev/null || true
    rm -rf "$SIGN_SCRIPT_DIR"

    cd "$WORK_DIR" || exit

    if [[ -f "create-signed-env.sh" ]]; then
        chmod +x create-signed-env.sh
        echo "===== Running create-signed-env.sh ====="
        printf '\n\n\n\n\n\n\n\n\n' | ./create-signed-env.sh
    else
        echo "❌ create-signed-env.sh not found!"
    fi
else
    echo "===== Skipping signing ====="
fi

# Build
if [[ "$START_BUILD" == true ]]; then
    echo "===== Starting build ====="

    source build/envsetup.sh
    eval "$LUNCH_CMD"
    eval "$BUILD_CMD"

    echo "===== Build started successfully! Check logs/output ====="
else
    echo "===== Build not started. Run manually when ready ====="
fi

echo "===== Script Finished ====="
