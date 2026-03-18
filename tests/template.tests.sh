#!/usr/bin/env bash

. "$(dirname "$0")/bash-spec.sh"

describe "template/empty branch" && {

  export TEST_DIR="/tmp/mnp-template-test"
  export MNP_DIR="$(cd "$(dirname "$0")/.." && pwd)"
  export MNP_NAME="$(basename "$MNP_DIR")"
  
  # Setup
  rm -rf "$TEST_DIR"
  mkdir -p "$TEST_DIR/dummy-project"
  git -C "$TEST_DIR/dummy-project" init -q
  echo "test" > "$TEST_DIR/dummy-project/test.txt"
  git -C "$TEST_DIR/dummy-project" add test.txt
  git -C "$TEST_DIR/dummy-project" commit -qm "init"
  
  context "when using template/empty with worktree:add" && {
    
    cd "$MNP_DIR"
    mise run pick "$TEST_DIR/dummy-project" > /dev/null
    mise run worktree:add empty-test template/empty
    RESULT=$?

    it "succeeds with exit code 0" && {
      expect "$RESULT" to_be 0
    }

    it "creates worktree from template/empty" && {
      [[ -d "$TEST_DIR/dummy-project/empty-test" ]]
      should_succeed
    }

    it "worktree is empty (no files)" && {
      count=$(ls -A "$TEST_DIR/dummy-project/empty-test" 2>/dev/null | grep -v '^\.git$' | wc -l)
      [[ "$count" -eq 0 ]]
      should_succeed
    }
  }
}
