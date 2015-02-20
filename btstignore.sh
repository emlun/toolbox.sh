#!/bin/bash

# Add ignore patterns for Syncthing files to BitTorrent Sync ignore file
cat << EOF >> .sync/IgnoreList

# Syncthing
.stfolder
.stignore
.stversions
EOF

# Add ignore patterns for Bittorrent Sync files to Syncthing ignore file
cat << EOF >> .stignore
// BitTorrent Sync
.sync
.SyncArchive
.SyncIgnore
SyncArchive
EOF
