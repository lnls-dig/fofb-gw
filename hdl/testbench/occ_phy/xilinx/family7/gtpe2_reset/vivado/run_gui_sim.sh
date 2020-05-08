#!/usr/bin/env bash

set -euo pipefail

# Run simulation
hdlmake makefile
make
xsim --file xsim.do &
