# Update repos
sudo apt update

# Install dependencies
sudo apt install bc bison build-essential kmod libncurses5 ccache curl flex g++-multilib gcc-multilib git git-lfs gnupg gperf nano imagemagick lib32ncurses5-dev lib32readline-dev lib32z1-dev liblz4-tool libncurses5 libncurses5-dev libsdl1.2-dev libssl-dev libwxgtk3.0-gtk3-dev libxml2 libxml2-utils lzop pngcrush rsync schedtool squashfs-tools xsltproc zip zlib1g-dev

# setup repo
mkdir ~/bin

# make path
PATH=~/bin:$PATH

# download repo
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo

# make repo executable
chmod a+x ~/bin/repo

# setup git account
git config --global user.name Thiago

# setup email
git config --global user.email thigo6617@gmail.com

# make dir
mkdir lineage2

# cd
cd lineage2

# init repo
repo init -u https://github.com/LineageOS/android.git -b lineage-18.1 --git-lfs

# clone manifest
git clone https://github.com/Samsung-SDM439/android_vendor_samsung_m01q.git -b lineage-18.1 /vendor/samsung/m01q
git clone https://github.com/smiley9000/android_device_samsung_sdm439.git -b Android-11 /device/samsung/sdm439
git clone https://github.com/Samsung-SDM439/caf_kernel_samsung_m01q.git /kernel/samsung/sdm439
# sync
repo sync -c --no-clone-bundle --optimized-fetch --prune --force-sync -j8
