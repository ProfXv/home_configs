# Set programs that you use
te=kitty
eo=rifle
al='$pkill wofi || wofi'

pkill fzf || {
    operation=`grep ^bind .config/hypr/* | fzf | awk -F, '{print $3 $4}'`
    hyprctl dispatch focuscurrentorlast
    eval hyprctl dispatch $operation
}
