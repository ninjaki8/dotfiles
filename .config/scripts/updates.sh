#!/bin/bash

count=$(checkupdates 2>/dev/null | wc -l)

if [ "$count" -eq 0 ] 2>/dev/null; then
    echo '{"text":"Up to date!","alt":"none","class":"none"}'
else
    echo '{"text":"New updates found ('$count')","alt":"updates","class":"updates"}'
fi