function compare_version() {
    # Compare two version strings and return "greater", "less" or "equal"
    if [[ $(echo -e "$1\n$2" | sort -V | head -n 1) = "$2" ]]; then
        echo "greater"
    elif [[ "$1" = "$2" ]]; then
        echo "equal"
    else
        echo "less"
    fi
}