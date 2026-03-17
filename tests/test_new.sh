#!/usr/bin/env bash

. "$(dirname "$0")/bash-spec.sh"

describe "mise-non-place CLI tasks" && {

  export TEST_DIR="/tmp/mnp-test-suite"
  
  # Setup function equivalent
  rm -rf "$TEST_DIR"
  mkdir -p "$TEST_DIR/dummy-project"
  git -C "$TEST_DIR/dummy-project" init -q
  echo "test" > "$TEST_DIR/dummy-project/test.txt"
  git -C "$TEST_DIR/dummy-project" add test.txt
  git -C "$TEST_DIR/dummy-project" commit -qm "init"
  
  context "when injecting an empty template" && {
    
    # We pipe "1\nmise\n" to select the first project and name it "mise"
    echo -e "1\nmise" | mise run new:empty "$TEST_DIR"
    RESULT=$?

    it "succeeds with exit code 0" && {
      expect "$RESULT" to_be 0
    }

    it "creates the hidden .mise-non-place clone" && {
      [[ -d "$TEST_DIR/dummy-project/.mise-non-place/.git" ]]
      should_succeed
    }

    it "creates the visible mise/ worktree" && {
      [[ -f "$TEST_DIR/dummy-project/mise/.git" ]]
      should_succeed
    }

    it "adds both folders to the target exclude file" && {
      grep -q "^.mise-non-place/$" "$TEST_DIR/dummy-project/.git/info/exclude"
      should_succeed

      grep -q "^mise/$" "$TEST_DIR/dummy-project/.git/info/exclude"
      should_succeed
    }
  }
  
  context "when removing the injected template" && {
    
    # Pipe "1" to confirm
    echo "1" | MISE_YES=1 mise run remove "$TEST_DIR" > /dev/null 2>&1
    RESULT=$?

    it "succeeds with exit code 0" && {
      expect "$RESULT" to_be 0
    }

    it "removes the worktree folder" && {
      [[ ! -d "$TEST_DIR/dummy-project/mise" ]]
      should_succeed
    }

    it "removes the .mise-non-place clone" && {
      [[ ! -d "$TEST_DIR/dummy-project/.mise-non-place" ]]
      should_succeed
    }

    it "cleans the exclude file" && {
      grep -q "^.mise-non-place/$" "$TEST_DIR/dummy-project/.git/info/exclude"
      should_fail

      grep -q "^mise/$" "$TEST_DIR/dummy-project/.git/info/exclude"
      should_fail
    }
  }
}
