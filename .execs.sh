# Set programs that you use
te=kitty
eo=rifle
al='pkill wofi || wofi'
sw="[float; size 960 540] $te"

pkill fzf || {
    operation=$(grep ^bind .config/hypr/* | fzf | awk -F, '
        {
            printf "\""
            for (i = 3; i <= NF; i++) {
                gsub(/^ *| *$/, "", $i)
                printf "%s ", $i
            }
            printf "\""
        }
    ')
    hyprctl dispatch focuscurrentorlast
    eval hyprctl dispatch $operation
    kill $KITTY_PID
}
