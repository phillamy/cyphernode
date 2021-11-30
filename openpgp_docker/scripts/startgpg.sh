#!/bin/sh

./gen-key.sh

mosquitto_sub -h broker -t gpg | ./requesthandler.sh
