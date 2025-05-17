#!/bin/bash


# Check for updates with yay
update_count=$(yay -Qu | wc -l)

# exit with 0 means it has updates
exit_code=$?

# Pad with leading zero if less than 10
if [[ $update_count -lt 10 ]]; then
  update_count="0$update_count"
fi

echo "󰏖 $update_count"
