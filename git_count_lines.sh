#!/bin/sh
# 

git log --author="Nestor Qin" --pretty=tformat: --numstat \
| gawk '{ add += $1; subs += $2; loc += $1 + $2 } END { printf "\nRepo:   Morphing World\nAuthor: Nestor Qin\n\n\033[32mAdded    lines: %s\n\033[31mRemoved  lines: %s\n\033[0mModified lines: %s\n", add, subs, loc }' -

git log --author="Hongxiao Lyu" --pretty=tformat: --numstat \
| gawk '{ add += $1; subs += $2; loc += $1 + $2 } END { printf "\nRepo:   Morphing World\nAuthor: Hongxiao Lyu\n\n\033[32mAdded    lines: %s\n\033[31mRemoved  lines: %s\n\033[0mModified lines: %s\n", add, subs, loc }' -

git log --author="Andrew Liu" --pretty=tformat: --numstat \
| gawk '{ add += $1; subs += $2; loc += $1 + $2 } END { printf "\nRepo:   Morphing World\nAuthor: Hongxiao Lyu\n\n\033[32mAdded    lines: %s\n\033[31mRemoved  lines: %s\n\033[0mModified lines: %s\n", add, subs, loc }' -

#git log --author="Nestor Qin" --pretty=tformat: --numstat \
#| awk '{ add += $1; subs += $2; loc += $1 - $2 } END { printf "Added lines: %s, Removed lines: %s, total lines: %s\n", add, subs, loc }' -
