#!/bin/bash

# Count the number of available updates
update_count=$(checkupdates 2>/dev/null | wc -l)

# If there are no updates, output "No Updates"
if [[ "$update_count" -eq 0 ]]; then
    echo "No Updates"
else
    echo "$update_count"
fi
