# Born2beroot

## Creation de la VM

- VirtualBox : Nouveau
- Name : On s'en tape
- Machine Folder : goinfre/sgoinfre
- Type : Linux
- Version : Debian 64-bit
- RAM : `1024 MB`
- Creer un disque dur virtuel : VDI : Fixed size : `30.8Gb`

---
## Installation debian11 (Bullseye)

- Install : Non Graphique
- Language : Anglais
- Territoire : Europe/France
- Hostname : cfrancie42
- Domain name : Rien
- Root password : Un Nom De Famille Allemand 
- Full name : Nom Et Prénom
- Username : cfrancie
- Password : Un Autre Nom De Famille Allemand 
- Time zone : France/Paris

###  Partitions

- https://youtu.be/2w-2MX5QrQw
- Configure the package manager : no
- Debian archive mirror country : France
- Mirror : deb.debian.org
- Participate in the package usage survey : <br/>
![Alt Text](https://media.tenor.com/RsAEE_fl9iwAAAAC/omar-sy.gif)
- Soft seclection: remove stars from ssh/standart system utilities/etc.
- GRUB : bah oui connard
- Installlation complee : continue

---
## Configuration

### Installation de configuration de sudo

```sh
$ su -
$ apt install vim
$ apt install sudo
$ adduser cfrancie sudo
$ sudo reboot
$ sudo -v
$ sudo addgroup user42
$ sudo adduser cfrancie user42
$ sudo apt update
$ sudo touch /etc/sudoers.d/sudoconfig
$ sudo mkdir /var/log/sudo
$ sudo vim /etc/sudoers.d/sudoconfig
```
- Ajoute ça dans le fichier sudoconfig
```sh
Defaults      passwd_tries=3
Defaults      badpass_message="Incorrect password"
Defaults      log_input,log_output
Defaults      iolog_dir="/var/log/sudo"
Defaults      requiretty
Defaults      secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"
```

### Installation et configuration de SSH

```sh
$ sudo apt install openssh-server
$ sudo vim /etc/ssh/sshd_config
```
- change le `#Port 22` en `Port 4242` et `#PermitRootLogin prohibit-password` en `PermitRootLogin no`
```sh
$ sudo vim /etc/ssh/ssh_config
```
- change le `#Port 22` en `Port 4242`
```sh
$ sudo service ssh status
```

### Installation et configuration de UFW
```sh
$ sudo apt install ufw
$ sudo ufw enable
$ sudo ufw allow 4242
$ sudo ufw status
```
### Mise en place d'une politique de mots de passe forts
```sh
$ sudo vim /etc/login.defs
```
- Modifie ça dans le fichier login.defs
```sh
PASS_MAX_DAYS    99999 -> PASS_MAX_DAYS    30
PASS_MIN_DAYS    0     -> PASS_MIN_DAYS    2 
```
```sh
$ sudo apt install libpam-pwquality
$ sudo vim /etc/pam.d/common-password
```
- Ajoute `minlen=10 ucredit=-1 dcredit=-1 maxrepeat=3 reject_username difok=7 enforce_for_root` à la fin du `password requisite pam_pwqiality.so retry=3` dans `common-password`

- Il faut mettre à jours les mots de passe (tu peux inverser les deux noms allemand)
```sh
$ passwd
$ sudo passwd
```

### Connexion SSH
- Maintenant tu dois pouvoir te connecter en ssh via un pc en local

```sh
$ sudo poweroff
```
- Configuration de la VM
- Réseaux -> Adapter 1 -> Advanced -> Redirection de ports
- Ajout d'une nouvelle regle
```
Protocole      IP Hôte       Port Hôte       IP invité      Port invité
TCP            127.0.0.1     4242            10.0.2.15      4242      
```
- Connecte toi en ssh
```sh
ssh cfrancie@localhost -p 4242
```

### Monitoring.sh

- Tu dois installer net-tools pour recupérer les infos requises
```sh
$ sudo apt install net-tools
```

## Bonus

### Installation Lighttpd

```sh
$ sudo apt install lighttpd
```
- Ouvre le port 80 (attribué par l'iana)
```sh
$ sudo ufw allow 80
```

### Installation et configuration de MariaDB

```sh
$ sudo apt install mariadb-server
```

```sh
$ sudo mysql_secure_installation
Enter current password for root (enter for none): # Enter
Set root password? [Y/n] n
Remove anonymous users? [Y/n] Y
Disallow root login remotely? [Y/n] Y
Remove test database and access to it? [Y/n] Y
Reload privilege tables now? [Y/n] Y

$ sudo mariadb
MariaDB [(none)]> CREATE DATABASE # Nom de la databse
MariaDB [(none)]> GRANT ALL ON <database-name>.* TO '<username-2>'@'localhost' IDENTIFIED BY '<password-2>' WITH GRANT OPTION;
MariaDB [(none)]> FLUSH PRIVILEGES;
MariaDB [(none)]> exit
$ mariadb -u <username-2> -p
MariaDB [(none)]> SHOW DATABASES;
MariaDB [(none)]> exit
```

### Installation de PHP

```sh
$ sudo apt install php-cgi php-mysql
```

### Installation et configuration de WordPress

```sh
$ sudo apt install wget
$ sudo wget http://wordpress.org/latest.tar.gz -P /var/www/html
$ sudo tar -xzvf /var/www/html/latest.tar.gz
$ sudo rm /var/www/html/latest.tar.gz
$ sudo cp -r /var/www/html/wordpress/* /var/www/html
$ sudo rm -rf /var/www/html/wordpress
$ sudo cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
$ sudo vi /var/www/html/wp-config.php
```

```sh
23 define( 'DB_NAME', 'database_name_here' );^M -> 23 define( 'DB_NAME', '<database-name>' );^M
26 define( 'DB_USER', 'username_here' );^M      -> 26 define( 'DB_USER', '<username-2>' );^M
29 define( 'DB_PASSWORD', 'password_here' );^M  -> 29 define( 'DB_PASSWORD', '<password-2>' );^M
```

### Configuraiton de Lighttpd

```sh
$ sudo lighty-enable-mod fastcgi
$ sudo lighty-enable-mod fastcgi-php
$ sudo service lighttpd force-reload
```

### Installation et configuration de FTP

```sh
$ sudo apt install vsftpd
$ sudo ufw allow 21
$ sudo vim /etc/vsftpd.conf
```
- `31 #write_enable=YES`

```sh
$ sudo mkdir /home/cfrancie/ftp
$ sudo mkdir /home/cfrancie/ftp/files
$ sudo chown nobody:nogroup /home/cfrancie/ftp
$ sudo chmod a-w /home/cfrancie/ftp
<~~~>
user_sub_token=$USER
local_root=/home/$USER/ftp
<~~~>
```
- `114 #chroot_local_user=YES`

```sh
$ sudo vi /etc/vsftpd.userlist
$ echo cfrancie | sudo tee -a /etc/vsftpd.userlist
<~~~>
userlist_enable=YES
userlist_file=/etc/vsftpd.userlist
userlist_deny=NO
<~~~>
```

- Connecte toi en FTP à ta VM `$ ftp <ip-address>` et quitte avec CTRL + D
- Tu peux installer un serveur minecraft si ça te chante