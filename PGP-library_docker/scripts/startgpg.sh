#!/bin/sh

. ./trace.sh

mosquitto_sub -h broker -t gpg | ./requesthandler.sh
