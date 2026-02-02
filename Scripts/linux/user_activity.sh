#!/bin/bash
# Generate user activity report from system logs

echo "========================================"
echo "USER ACTIVITY REPORT - $(date)"
echo "========================================"

echo -e "\n-- Recent Logins --"
last -n 10

echo -e "\n-- Active Sessions --"
who

echo -e "\n-- Failed Login Attempts --"
grep "Failed password" /var/log/auth.log 2>/dev/null | tail -5 || echo "None"

echo -e "\n-- Account Changes --"
grep -E "useradd|usermod|groupadd" /var/log/auth.log 2>/dev/null | tail -5 || echo "None"

echo "========================================"
