#!/bin/bash

# Run yay with noconfirm and quiet flags
update_count=$(yay -Qu --noconfirm 2>/dev/null | wc -l)

# Pad with leading zero if less than 10
if [[ $update_count -lt 10 ]]; then
  update_count="0$update_count"
fi

echo "󰏖 $update_count"
