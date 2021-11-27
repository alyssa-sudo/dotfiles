#!/usr/bin/env bash
theme="launcher"

dir="/etc/xdg/openbox"
styles=($(ls -p $dir/launcher))

rofi -no-lazy-grab -show drun \
-modi drun \
-theme $dir/"$theme"
