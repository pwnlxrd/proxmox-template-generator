echo " ######                                               #######                                                     #####                                                         "
echo " #     # #####   ####  #    # #    #  ####  #    #       #    ###### #    # #####  #        ##   ##### ######    #     # ###### #    # ###### #####    ##   #####  ####  #####  "
echo " #     # #    # #    #  #  #  ##  ## #    #  #  #        #    #      ##  ## #    # #       #  #    #   #         #       #      ##   # #      #    #  #  #    #   #    # #    # "
echo " ######  #    # #    #   ##   # ## # #    #   ##         #    #####  # ## # #    # #      #    #   #   #####     #  #### #####  # #  # #####  #    # #    #   #   #    # #    # "
echo " #       #####  #    #   ##   #    # #    #   ##         #    #      #    # #####  #      ######   #   #         #     # #      #  # # #      #####  ######   #   #    # #####  "
echo " #       #   #  #    #  #  #  #    # #    #  #  #        #    #      #    # #      #      #    #   #   #         #     # #      #   ## #      #   #  #    #   #   #    # #   #  "
echo " #       #    #  ####  #    # #    #  ####  #    #       #    ###### #    # #      ###### #    #   #   ######     #####  ###### #    # ###### #    # #    #   #    ####  #    # "

read -p 'Template ID: ' id
read -p 'Image path: ' imgname
read -p 'Username: ' username
read -p 'SSH public key: ' sshpub
read -p 'Template name: ' templatename
read -p 'Proxmox data disk name: ' disk

echo "Install libguestfs-tools..."
apt install libguestfs-tools -y

echo "Custmize img..."
virt-customize -a $imgname --install qemu-guest-agent
virt-customize -a $imgname --run-command 'useradd -ms /bin/bash $username; mkdir -p /home/$username/.ssh; echo "$sshpub" > /home/$username/.ssh/authorized_keys; chown -R $username:$username /home/$username'

echo "Create VM..."
qm create $id --name "$templatename" --memory 1024 --cores 1 --net0 virtio,bridge=vmbr0
qm importdisk $id $imgname $disk
qm set $id --scsihw virtio-scsi-pci --scsi0 $disk:vm-disk-0-template-$id
qm set $id --boot c --bootdisk scsi0
qm set $id --ide2 $disk:cloudinit
qm set $id --serial0 socket --vga serial0
qm set $id --agent 1

echo "Create template..."
qm template $id

echo "done"