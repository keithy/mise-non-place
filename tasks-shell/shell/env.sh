#!/usr/bin/env bash
#MISE description="show task running environment"

export PATH="$MISE_TASK_DIR/../../bin:$PATH"
env | grep "${1:-}" | obfuscate
