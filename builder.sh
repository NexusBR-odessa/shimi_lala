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
repo init -u https://github.com/LineageOS/android.git -b lineage-18.1 --git-lfs

# clone manifest
git clone https://github.com/NexusBR-odessa/local_manifest_a01q.git -b main .repo/local_manifests

# sync
repo sync -c --no-clone-bundle --optimized-fetch --prune --force-sync
