#!/bin/bash

echo "===== Welcome to Builder script created by Miguel Barreto ====="

# Pergunta única para update + dependências
read -p "Wait, are you in ServerHive? (y/n): " setup_choice

if [[ "$setup_choice" == "y" || "$setup_choice" == "Y" ]]; then
    echo "===== Ok, so lets update the dependencies ====="
    sudo apt update

    echo "===== Installing dependencies ====="
    sudo apt install -y bc bison build-essential ccache curl flex g++-multilib gcc-multilib git git-lfs gnupg gperf imagemagick lib32ncurses5-dev lib32readline-dev lib32z1-dev liblz4-tool libncurses5 libncurses5-dev libsdl1.2-dev libssl-dev libwxgtk3.0-gtk3-dev libxml2 libxml2-utils lzop pngcrush rsync schedtool squashfs-tools xsltproc zip zlib1g-dev
else
    echo "===== In ServerHive, all the dependencies are already installed ====="
fi

echo ""
echo "===== Repo configuration ====="

# Escolha obrigatória do repo
while true; do
    read -p "Enter manifest URL: " repo_url
    [[ -n "$repo_url" ]] && break || echo "URL cannot be empty."
done

while true; do
    read -p "Enter branch: " repo_branch
    [[ -n "$repo_branch" ]] && break || echo "Branch cannot be empty."
done

echo "===== Using configuration ====="
echo "URL: $repo_url"
echo "Branch: $repo_branch"

# setup repo
mkdir -p ~/bin
export PATH=~/bin:$PATH

curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod a+x ~/bin/repo

echo ""
echo "===== Git configuration ====="

# Git user
while true; do
    read -p "Enter your GitHub username: " git_name
    [[ -n "$git_name" ]] && break || echo "Username cannot be empty."
done

# Git email
while true; do
    read -p "Enter your GitHub email: " git_email
    [[ -n "$git_email" ]] && break || echo "Email cannot be empty."
done

git config --global user.name "$git_name"
git config --global user.email "$git_email"

# Diretório
mkdir -p lineage2
cd lineage2 || exit

# Init repo
echo ""
echo "===== Initializing repo ====="
repo init -u "$repo_url" -b "$repo_branch" --git-lfs

echo ""
echo "===== Local manifest setup ====="

read -p "Do you want to use Odessa manifests? (y/n): " use_odessa

if [[ "$use_odessa" == "y" || "$use_odessa" == "Y" ]]; then
    echo "===== Cloning Odessa manifests ====="
    git clone https://github.com/NexusBR-odessa/local_manifests_odessa.git -b 16.0-QPR2 .repo/local_manifests
else
    echo "===== Custom manifest selected ====="

    while true; do
        read -p "Enter your manifest repo URL: " manifest_url
        [[ -n "$manifest_url" ]] && break || echo "URL cannot be empty."
    done

    read -p "Enter manifest branch (default: main): " manifest_branch
    manifest_branch=${manifest_branch:-main}

    echo "===== Cloning custom manifest ====="
    git clone "$manifest_url" -b "$manifest_branch" .repo/local_manifests
fi

# Sync (duas vezes)
echo ""
echo "===== Syncing sources (1/2) ====="
repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags

echo ""
echo "===== Running second sync to ensure everything is up-to-date (2/2) ====="
repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags

echo ""
echo "===== ROM Signing ====="

read -p "Do you want to sign the ROM? (y/n): " sign_choice

if [[ "$sign_choice" == "y" || "$sign_choice" == "Y" ]]; then
    echo "===== Setting up signing environment ====="

    cd .. || exit
    git clone https://github.com/crdroidandroid/crDroid-build-signed-script.git

    mv crDroid-build-signed-script/* lineage2
    rm -rf crDroid-build-signed-script

    cd lineage2 || exit

    chmod +x create-signed-env.sh

    echo "===== Running signing script ====="
    printf '\n\n\n\n\n\n\n\n\n' | ./create-signed-env.sh
else
    echo "===== Skipping ROM signing ====="
fi

echo ""
echo "===== Build Setup ====="

build_started=false

read -p "Do you want to start the build now? (y/n): " build_choice

if [[ "$build_choice" == "y" || "$build_choice" == "Y" ]]; then
    echo "===== Setting up build environment ====="
    source build/envsetup.sh

    echo ""
    read -p "Enter lunch command (example: lunch lineage_device-userdebug): " lunch_cmd

    if [[ -n "$lunch_cmd" ]]; then
        eval "$lunch_cmd"
    else
        echo "===== Lunch command cannot be empty ====="
        exit 1
    fi

    echo ""
    read -p "Enter build command (example: mka bacon): " build_cmd

    if [[ -n "$build_cmd" ]]; then
        echo "===== Starting build ====="
        build_started=true
        eval "$build_cmd"
    else
        echo "===== Build command cannot be empty ====="
        exit 1
    fi
else
    echo "===== Build skipped ====="
fi

echo ""
echo "===== Script Finished ====="

if [[ "$build_started" == true ]]; then
    echo "===== Build started successfully! Check your build output above or logs. ====="
else
    echo "===== You can start the build manually when ready. ====="
fi
