# Hard drive failing, trying to save the data.

sudo mount -r /dev/sdj1 /mnt/SG-4TB-3/
sudo rsync --verbose -r /mnt/SG-4TB-3/Media/ /mnt/SG-6TB-2/tmp/

