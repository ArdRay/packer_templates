# Documentation - Rocky CIS: https://www.tenable.com/audits/CIS_Rocky_Linux_9_v1.0.0_L2_Server
# Documentation - RHEL Kickstart: https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/installation_guide/sect-kickstart-syntax

# Sets up the authentication options for the system
authselect minimal

# Causes the installer to ignore the specified disks.
ignoredisk --only-use=sda

# Removes partitions from the system, prior to creation of new partitions.
clearpart --none --initlabel

# Install from the first optical drive on the system. 
cdrom

# Perform the kickstart installation in text mode.
text

# Keyboard layouts
keyboard --vckeymap=us --xlayouts='us'

# System language
lang en_US.UTF-8

# Network information
network  --bootproto=dhcp --ipv6=auto --activate --onboot=yes

# Repo information
repo --name="AppStream" --baseurl=https://dl.rockylinux.org/pub/rocky/9.2/AppStream/x86_64/kickstart/ --install
repo --name="EPEL" --baseurl=https://dl.fedoraproject.org/pub/epel/9/Everything/x86_64/ --install

# Root password
rootpw --iscrypted $6$eof03f$Vg.Du8K94G23m7tQz9Op2l3g85ncPCmcZmSTg1dR770kFsdtswMrI9o2/6YNAuRtW4w3VkkTmcveAkEvbrzdk1

# Determine whether the firstboot starts the first time the system is booted.
firstboot --disabled

# If present, X is not configured on the installed system. 
skipx

# System services
services --disabled="kdump" --enabled="sshd,rsyslog,chronyd,qemu-guest-agent"

# System timezone
timezone Europe/Zurich

# Disk partitioning information
part /dev/shm --fsoptions="nodev,nosuid,noexec"
part /boot --size 512 --asprimary --fstype=ext4 --ondrive=sda --label=boot
part pv.1 --size 1 --grow --fstype=ext4 --ondrive=sda

volgroup system --pesize=1024 pv.1

logvol / --fstype ext4 --vgname system --size=4096 --name=root
logvol /var --fstype ext4 --vgname system --size=16384 --name=var --fsoptions="nodev,nosuid"
logvol /home --fstype ext4 --vgname system --size=2048 --name=home --fsoptions="nodev,nosuid"
logvol /tmp --fstype ext4 --vgname system --size=1024 --name=tmp --fsoptions="nodev,nosuid,noexec"
logvol swap --vgname system --size=2048 --name=swap
logvol /var/log --fstype ext4 --vgname system --size=1024 --name=var_log --fsoptions="nodev,nosuid,noexec"
logvol /var/tmp --fstype ext4 --vgname system --size=2048 --name=var_tmp --fsoptions="nodev,nosuid,noexec"
logvol /var/log/audit --fstype=ext4 --vgname=system --size=512 --name=var_log_audit --fsoptions="nodev,nosuid,noexec"
reboot

%packages
@^minimal-environment
qemu-guest-agent
openssh-server
openssh-clients
epel-release

# Ansible
python3
python3-libselinux
ansible

# Utils
curl
unzip
net-tools

# unnecessary firmware
-aic94xx-firmware
-atmel-firmware
-b43-openfwwf
-bfa-firmware
-ipw2100-firmware
-ipw2200-firmware
-ivtv-firmware
-iwl100-firmware
-iwl1000-firmware
-iwl3945-firmware
-iwl4965-firmware
-iwl5000-firmware
-iwl5150-firmware
-iwl6000-firmware
-iwl6000g2a-firmware
-iwl6050-firmware
-libertas-usb8388-firmware
-ql2100-firmware
-ql2200-firmware
-ql23xx-firmware
-ql2400-firmware
-ql2500-firmware
-rt61pci-firmware
-rt73usb-firmware
-xorg-x11-drv-ati-firmware
-zd1211-firmware
-linux-firmware

# CIS compliance
-gdm
-xorg-x11*
-avahi*
-cups
-dhcp-server
-bind
-vsftpd
-tftp-server
-httpd
-dovecot
-cyrus-imapd
-samba
-squid
-net-snmp
-telnet-server
-dnsmasq
-nfs-utils
-rpcbind
-rsync-daemon
-telnet
-openldap-clients
-tftp
-ftp
%end

%addon com_redhat_kdump --disable
%end

%post

# AppStream trusted GPG key
rpm --import https://dl.rockylinux.org/pub/rocky/RPM-GPG-KEY-Rocky-9
# EPEL 9 GPG key
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-9

# Temporarily - For provisioning
echo "PermitRootLogin yes" > /etc/ssh/sshd_config.d/allow-root-ssh.conf

dnf update -y
dnf clean all
%end

