#!/bin/sh

read line
echo "${line}" 1>&2
echo -n "HTTP/1.1 200 OK\r\n"
echo "Content-Type: application/json\r\nContent-Length: 0\r\n\r\n"

# Small delay needed for the data to be processed correctly by peer
sleep 0.5s
