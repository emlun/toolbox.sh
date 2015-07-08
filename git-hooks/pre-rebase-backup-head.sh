#!/bin/bash
# git hook for use as .git/hooks/pre-rebase
#
# Backs up the current HEAD to refs/pre-rebase-backup before rebasing. Rotates
# backup refs and throws them away eventually.

BAK=.git/refs/pre-rebase-backup
for i in {2..1}; do
  if [[ -f $BAK-$i ]]; then
    mv -f $BAK-$i $BAK-$((i+1)) || exit $?
  fi
done

if [[ -f $BAK ]]; then
  mv -f $BAK $BAK-1 || exit $?
fi

git rev-parse HEAD > $BAK
