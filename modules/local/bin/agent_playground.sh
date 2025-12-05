#!/bin/sh

while [ $# -gt 0 ]; do
    case "$1" in
        -t|--terminal)
            TYPE="terminal"
            shift
            ;;
        -T|--termate)
            TYPE="termate"
            shift
            ;;
        -c|--command)
            CMD="$2"
            shift 2
            ;;
        --)
            shift
            break
            ;;
        -*)
            echo "Unknown option: $1"
            exit 1
            ;;
        *)
            break
            ;;
    esac
done

DIR="${1:-$(pwd)}"
DIR="$(realpath -m "$DIR")"
CMD="${2:-$CMD}"
CMD="zsh${CMD:+ -c \"$CMD\"}"

echo "=== Sandbox Environment ==="
echo "Directory: $DIR"
echo "Command: $CMD"
echo ""

BWOPTS="--unshare-all --share-net --ro-bind / /"
BWOPTS="$BWOPTS --dev /dev"
BWOPTS="$BWOPTS --proc /proc"
BWOPTS="$BWOPTS --tmpfs /tmp"
case "$TYPE" in
    terminal)
        BWOPTS="$BWOPTS --bind /home/paradoxist/.zsh_history /home/paradoxist/.zsh_history"
        ;;
    termate)
        BWOPTS="$BWOPTS --bind /home/paradoxist/Documents/conversations /home/paradoxist/Documents/conversations"
        ;;
esac
BWOPTS="$BWOPTS --bind \"$DIR\" \"$DIR\""

eval "exec bwrap $BWOPTS --chdir \"$DIR\" $CMD"
