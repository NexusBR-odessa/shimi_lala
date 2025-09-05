# Update repos
sudo apt update

# Install dependencies
sudo apt install bc bison build-essential ccache curl flex g++-multilib gcc-multilib git git-lfs gnupg gperf imagemagick lib32ncurses5-dev lib32readline-dev lib32z1-dev liblz4-tool libncurses5 libncurses5-dev libsdl1.2-dev libssl-dev libwxgtk3.0-gtk3-dev libxml2 libxml2-utils lzop pngcrush rsync schedtool squashfs-tools xsltproc zip zlib1g-dev

# setup repo
mkdir ~/bin

# make path
PATH=~/bin:$PATH

# download repo
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo

# make repo executable
chmod a+x ~/bin/repo

# setup git account
git config --global user.name NexusBR-odessa

# setup email
git config --global user.email miguel03barreto@gmail.com

# make dir
mkdir lineage2

# cd
cd lineage2

# init repo
repo init -u https://github.com/LineageOS/android.git -b lineage-22.1 --git-lfs

# clone manifest
git clone https://github.com/NexusBR-odessa/local_manifest_odessa15.git -b 15.0-QPR1 .repo/local_manifests

# sync
repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags
