echo " ######                                               #######                                                     #####                                                         "
echo " #     # #####   ####  #    # #    #  ####  #    #       #    ###### #    # #####  #        ##   ##### ######    #     # ###### #    # ###### #####    ##   #####  ####  #####  "
echo " #     # #    # #    #  #  #  ##  ## #    #  #  #        #    #      ##  ## #    # #       #  #    #   #         #       #      ##   # #      #    #  #  #    #   #    # #    # "
echo " ######  #    # #    #   ##   # ## # #    #   ##         #    #####  # ## # #    # #      #    #   #   #####     #  #### #####  # #  # #####  #    # #    #   #   #    # #    # "
echo " #       #####  #    #   ##   #    # #    #   ##         #    #      #    # #####  #      ######   #   #         #     # #      #  # # #      #####  ######   #   #    # #####  "
echo " #       #   #  #    #  #  #  #    # #    #  #  #        #    #      #    # #      #      #    #   #   #         #     # #      #   ## #      #   #  #    #   #   #    # #   #  "
echo " #       #    #  ####  #    # #    #  ####  #    #       #    ###### #    # #      ###### #    #   #   ######     #####  ###### #    # ###### #    # #    #   #    ####  #    # "

id = "9000"
imgname = "/data_vm/template/iso/hirsute-server-cloudimg-amd64.img"
username = "pwnlxrd"
sshpub = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDInLYOpvD79tTAK0JnXAYtl7OunvgGBT/GisorX2ELuhF1AFWZg9tYQ8fsMEtb6pkErj5te77Qmi9qxB8FNX2zNoATIMDORG9RdOo7A0TxJ/n4JaT2Uki8nPi3tQCqJ8lTuTY8H2AEwLRj1NbvG/PmNGOZORJtQMwCLUOKxD0IbQpR3ebgDvSu/W6ZE4rcP/xmP1d71Lxt0CrPcz39jiUhG9m8vSMd0Sx+Q19MP5lZTz+Pc/VQipjurO4joGXaKQdBkQwmwpDBf2jQmBa3tLtqabzhjC/gKwFQ17O1jmrySlrngsieLaZaJmDUvUXInAozXKN+4jTcXExPpdiWn7zPkkx5P+/0THvev8Kdb1HUXFPOAYzp68gXLcswF0GQI6sl8eplhWPxxM7qECa4jZTsCLrB1lVDxJwGqYCRT0NyjUFdlUyg9oBuIiLHI3ZnX4XXbfgMwcxPNT2quEADjuO33iLad9TvtTtk1YnBw2cb1PRC/BS4oiswE2+I+Lyhswk="
templatename = "ubuntu-hirsute"
template_description = "ubuntu hirsute cloud-init template"
disk = "vm_data"

echo "Install libguestfs-tools..."
apt install libguestfs-tools -y

echo "Custmize img..."
virt-customize -a $imgname --install qemu-guest-agent
virt-customize -a $imgname --run-command 'useradd -ms /bin/bash $username; mkdir -p /home/$username/.ssh; echo "$sshpub" > /home/$username/.ssh/authorized_keys; chown -R $username:$username /home/$username'

echo "Create VM..."
qm create $id --name $templatename --memory 1024 --net0 virtio,bridge=vmbr0,tag=10 --cores 1 --sockets 1 --cpu cputype=kvm64 --description "$template_description" --kvm 1 --numa 1
qm importdisk $id $imgname $disk
qm set $id --scsihw virtio-scsi-pci --virtio0 $disk:"$id"-vm-disk-1
qm set $id --serial0 socket
qm set $id --boot c --bootdisk virtio0
qm set $id --agent 1
qm set $id --hotplug disk,network,usb,memory,cpu
qm set $id --vcpus 1
qm set $id --vga qxl
qm set $id --name glusterfs-micro
#Cloud INIT
qm set $id --ide2 $disk:cloudinit
#qm set $id --sshkey ssh-pub-key/pub1

echo "Create template..."
qm template $id

echo "done"

