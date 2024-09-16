ping example.com || echo Network Error, please check and try again. && exit
echo WARNING: ONLY BARE MACHINES CAN EXECUTE THIS SCRIPT FOR AUTOMATIC CONFIGURATION
echo By typing your password, you admit you are fully aware of the risk, and we start.
cd ~

sudo sed -i 's/#zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/g' /etc/locale.gen
sudo locale-gen

sudo pacman -Sy git clash

clash=.config/clash/config.yaml
if [ ! -f $clash ]; then curl https://update.glados-config.com/clash/290141/765f3fd/50821/glados-terminal.yaml > $clash; fi
sed -i 's/external-ui: dashboard/# external-ui: dashboard/g' $clash
clash -d .config/clash/ &
export http_proxy=127.0.0.1:7890 https_proxy=127.0.0.1:7890 all_proxy=127.0.0.1:7890

git clone -n https://github.com/ProfXv/home_configs --branch=hyprland
mv -i home_configs/.git .
rm -rf home_configs
git checkout -f
git remote set-url origin git@github.com:ProfXv/home_configs.git

for p in `cat .packages`; do sudo pacman -S --needed --noconfirm $p || echo $p >> failures.txt; done
sudo pacman -R --noconfirm nano

git clone https://aur.archlinux.org/yay.git
cd yay 
makepkg -si
cd ..
rm -rf yay

for p in `cat .opt_packages`; do yay -S $p || echo $p >> failures.txt; done

for repo in github gitlab; do
	case $repo in
		github) mail=849460963@qq.com;;
		gitlab) mail=xuenqiao@swarma.org;;
	esac
	mkdir -p .ssh/$repo
	ssh-keygen -t rsa -C $mail -N '' -f .ssh/$repo/id_rsa
done

chsh -s `which zsh`

iwctl station wlan0 connect Gaia-5G -P 6.62606896%Planck
systemctl enable bluetooth.service
systemctl enable iwd.service
systemctl enable runsunloginclient.service
systemctl enable cronie.service
sudo systemctl enable minidina.service
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

echo Initialization Completed.
wget https://github.com/vial-kb/vial-gui/releases/download/v0.7.1/Vial-v0.7.1-x86_64.AppImage -P ~/Desktop
chmod +x ~/Desktop/Vial-v0.7.1-x86_64.AppImage
sudo usermod -aG input `whoami`
