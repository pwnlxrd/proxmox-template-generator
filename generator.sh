echo " ######                                               #######                                                     #####                                                         "
echo " #     # #####   ####  #    # #    #  ####  #    #       #    ###### #    # #####  #        ##   ##### ######    #     # ###### #    # ###### #####    ##   #####  ####  #####  "
echo " #     # #    # #    #  #  #  ##  ## #    #  #  #        #    #      ##  ## #    # #       #  #    #   #         #       #      ##   # #      #    #  #  #    #   #    # #    # "
echo " ######  #    # #    #   ##   # ## # #    #   ##         #    #####  # ## # #    # #      #    #   #   #####     #  #### #####  # #  # #####  #    # #    #   #   #    # #    # "
echo " #       #####  #    #   ##   #    # #    #   ##         #    #      #    # #####  #      ######   #   #         #     # #      #  # # #      #####  ######   #   #    # #####  "
echo " #       #   #  #    #  #  #  #    # #    #  #  #        #    #      #    # #      #      #    #   #   #         #     # #      #   ## #      #   #  #    #   #   #    # #   #  "
echo " #       #    #  ####  #    # #    #  ####  #    #       #    ###### #    # #      ###### #    #   #   ######     #####  ###### #    # ###### #    # #    #   #    ####  #    # "

image_url="https://cloud-images.ubuntu.com/hirsute/current/hirsute-server-cloudimg-amd64.img"
id="9000"
imgname="/tmp/hirsute-server-cloudimg-amd64.img"
username="pwnlxrd"
sshpub="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDInLYOpvD79tTAK0JnXAYtl7OunvgGBT/GisorX2ELuhF1AFWZg9tYQ8fsMEtb6pkErj5te77Qmi9qxB8FNX2zNoATIMDORG9RdOo7A0TxJ/n4JaT2Uki8nPi3tQCqJ8lTuTY8H2AEwLRj1NbvG/PmNGOZORJtQMwCLUOKxD0IbQpR3ebgDvSu/W6ZE4rcP/xmP1d71Lxt0CrPcz39jiUhG9m8vSMd0Sx+Q19MP5lZTz+Pc/VQipjurO4joGXaKQdBkQwmwpDBf2jQmBa3tLtqabzhjC/gKwFQ17O1jmrySlrngsieLaZaJmDUvUXInAozXKN+4jTcXExPpdiWn7zPkkx5P+/0THvev8Kdb1HUXFPOAYzp68gXLcswF0GQI6sl8eplhWPxxM7qECa4jZTsCLrB1lVDxJwGqYCRT0NyjUFdlUyg9oBuIiLHI3ZnX4XXbfgMwcxPNT2quEADjuO33iLad9TvtTtk1YnBw2cb1PRC/BS4oiswE2+I+Lyhswk="
templatename="ubuntu-hirsute"
template_description="ubuntu hirsute cloud-init template"
disk="vm_data"

echo "Download ubuntu hirsute..."
wget $image_url

echo "Install libguestfs-tools..."
apt install libguestfs-tools -y

echo "Custmize img..."
virt-customize -a $imgname --install qemu-guest-agent
echo "Create VM..."
qm create $id  --name $templatename --memory 1024 --cores 1 --sockets 1 --net0 virtio,bridge=vmbr0
qm importdisk $id $imgname $disk
qm set $id --scsihw virtio-scsi-pci --scsi0 $disk:$id/vm-$id-disk-0.raw --ide2 $disk:cloudinit --boot c --bootdisk scsi0 --serial0 socket --vga serial0 --agent 1

echo "Set user - $username"
qm set $id --ciuser $username

echo "Set public ssh key"
qm set $id --sshkeys "$sshpub"
