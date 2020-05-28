#!/usr/bin/env bash

set -euo pipefail

# Run simulation
hdlmake -a makefile
make
vsim -i -do run.do &
