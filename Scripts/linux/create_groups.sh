#!/bin/bash
# Create organizational groups and assign users

set -e

echo "Creating groups..."

for group in Teachers Students Staff All_Staff; do
    groupadd "$group" 2>/dev/null && echo "[OK] $group" || echo "[SKIP] $group exists"
done

echo "Assigning users to groups..."

usermod -aG Teachers,All_Staff jsmith
usermod -aG Teachers,All_Staff mgarcia
usermod -aG Students,All_Staff twilliams
usermod -aG Students,All_Staff alee
usermod -aG Staff,All_Staff bjohnson

echo "Done."
