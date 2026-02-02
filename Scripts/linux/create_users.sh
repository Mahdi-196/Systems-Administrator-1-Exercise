#!/bin/bash
# Create organizational users with forced password rotation

set -e

USERS=("jsmith:John Smith" "mgarcia:Maria Garcia" "twilliams:Tom Williams" "alee:Alice Lee" "bjohnson:Bob Johnson")
DEFAULT_PASS="TempPass123!"

echo "Creating users..."

for entry in "${USERS[@]}"; do
    IFS=':' read -r username fullname <<< "$entry"

    if id "$username" &>/dev/null; then
        echo "[SKIP] $username exists"
    else
        useradd -m -s /bin/bash -c "$fullname" "$username"
        echo "$username:$DEFAULT_PASS" | chpasswd
        chage -d 0 "$username"
        echo "[OK] $username"
    fi
done

echo "Done. Users must change password on first login."
