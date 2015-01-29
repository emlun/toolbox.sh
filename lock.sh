#!/bin/bash

systemctl --user stop unclutter
DISPLAY=:0 slock
systemctl --user start unclutter
