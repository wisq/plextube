args_dir="$1"

(
	while [ "$#" -gt 0 ]; do
		echo "$1"
		shift
	done
) > "$args_dir/args"
