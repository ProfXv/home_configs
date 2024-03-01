echo WARNING: ONLY BARE MACHINES CAN EXECUTE THIS SCRIPT FOR AUTOMATIC CONFIGURATION
echo By typing your password, you admit you are fully aware of the risk, and we start.
chsh -s `which zsh`

sudo sed -i 's/#zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/g' /etc/locale.gen
sudo locale-gen

sudo pacman -Sy git
git config --global user.email "nparadoxist@gmail.com"
git config --global user.name "Paradoxist@Paradoxer"

cd ~
git clone -n https://github.com/ProfXv/home_configs
mv -i home_configs/.git/ .
rm -r home_configs/
git checkout -f
git remote remove origin
git remote add origin git@github.com:ProfXv/home_configs.git

curl https://update.glados-config.com/clash/290141/765f3fd/50821/glados-terminal.yaml > .proxy.yaml
sed -i 's/external-ui: dashboard/# external-ui: dashboard/g' .proxy.yaml
clash &

sudo pacman -S --needed --noconfirm `cat .packages`
sudo pacman -Rs --noconfirm xterm nano

git clone https://aur.archlinux.org/yay.git
cd yay 
makepkg -si
cd ..
rm -rf yay

yay -S `cat .opt_packages`

for repo in github gitlab; do
	case $repo in
		github) mail=849460963@qq.com;;
		gitlab) mail=xuenqiao@swarma.org;;
	esac
	mkdir -p .ssh/$repo
	ssh-keygen -t rsa -C $mail -N '' -f .ssh/$repo/id_rsa
done

systemctl enable bluetooth.service
# for device in D1:00:FF:11:15:5B 20:73:34:03:20:94; do
#     echo "Processing $DEVICE"
#     bluetoothctl << EOF
# scan on
# devices
# pair $device
# connect $device
# trust $device
# EOF
# done
# 
# for device in D1:00:FF:11:15:5B 20:73:34:03:20:94; do for act in pair connect trust; do bluetoothctl $act $device; done; done

reboot
