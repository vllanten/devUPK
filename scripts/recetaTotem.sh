#!/bin/bash
# Configura la base para un totem

echo -e " -> Comenzando la instalación"
read -p "Ingresa el usuario usuario: " USER

echo -e " -> Instalando aplicaciones requeridas"
# Instalaciones de aplicaciones requeridas
apt-get update
apt-get install -qy sudo vim git openssh-client xfce4 curl openssh-server openvpn chromium apt-transport-https ca-certificates gnupg2  software-properties-common

echo -e " -> Instalando docker"
# Instalacion de docker
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" && apt-get update
sudo apt-get install docker-ce -y

echo -e " -> Instalando utilidades de video"
# Instalación de utilidades de video
apt install -qy ffmpeg libavcodec-extra gstreamer1.0-fluendo-mp3 gstreamer1.0-plugins-ugly gstreamer1.0-plugins-bad gstreamer1.0-pulseaudio vorbis-tools

echo -e " -> Removiendo xfce4-panel"
apt-get remove -qy xfce4-panel

echo -e " -> Cancelando unattended-upgrades"
# Cancelar updates
sudo apt-get -qy install unattended-upgrades
sudo apt-get -qy purge unattended-upgrades

echo -e " -> Instalando teamviewer"
# TeamViewer
wget http://download.teamviewer.com/download/version_12x/teamviewer_i386.deb
dpkg --add-architecture i386 && apt-get update
dpkg -i --force-depends teamviewer_i386.deb
apt-get install -f

echo -e " -> Configurando SSH_Server"
# Ajustes del SSH server
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

echo -e " -> Configurando GRUB"
# Ajustes del GRUB
sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/' /etc/default/grub
sudo update-grub && sudo update-grub2

echo -e " -> Preparando autoLogin"
# Preparación del auto-login
groupadd -r autologin
gpasswd -a $USER autologin

# Ajustes para el autologin
cp /etc/lightdm/lightdm.conf{,.old}
echo -e "#
[LightDM]
#
[Seat:*]
pam-service=lightdm
pam-autologin-service=lightdm-autologin
# xserver-command=X -nocursor
greeter-session=ligthdm-greeter
session-wrapper=/etc/X11/Xsession
autologin-user=$USER
autologin-user-timeout=0
#
[XDMCPServer]\n
#
[VNCServer]
#" > /etc/lightdm/lightdm.conf 

echo -e " -> Creando Script autoStart"
# Script autologin
echo -e "#!/bin/sh
xrandr --output HDMI-0 --mode 1920x1080 --rate 30 --display :0
sleep 10
xset s off
xset dpms 0 0 0
xset -dpms s off
chromium --kiosk --incognito  --disable-session-crashed-bubble --disable-infobars --disable-translate  www.icluster.cl" > /home/$USER/startApp.sh

chmod +x /home/$USER/startApp.sh

mkdir -p /home/$USER/.config/autostart
chown $USER.$USER /home/$USER/.config/autostart
chmod 777 /home/$USER/.config/autostart

echo -e "[Desktop Entry]
Encoding=UTF-8
Version=0.9.4
Type=Application
Name=autoStart
Comment=autoStart
Exec=/home/$USER/startApp.sh
OnlyShowIn=XFCE;
StartupNotify=false
Terminal=false
Hidden=true" > /home/$USER/.config/autostart/startApp.desktop

# echo "/bin/bash /home/$USER/startApp.sh" > /home/$USER/.config/xfce4/xinitrc

echo -e "#########################################################
Fin del proceso!!, recuerda poner atención a las configuraciones manuales
#########################################################
# Configuraciones y revisiones manuales
## Habilitar el autoStart de la aplicacion
## Configurar teamviewer
## RED (revisar que tenga dhcp)
## Auto arranque al cortarse la luz en la BIOS
## Configurar las politicas de chrome
	# autoplay
	# translate
## configurar la vpn"
