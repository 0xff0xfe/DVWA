#!/bin/bash
# Check if Apache server is running
systemctl status apache2 | grep 'active (running)' || exit 1
