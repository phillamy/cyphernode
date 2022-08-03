#!/bin/bash
set -e

/usr/bin/xvfb-run -a /usr/local/bin/wassabee mix --wallet:not-mixed-yet --keepalive 
