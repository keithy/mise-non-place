#!/usr/bin/env bash

. "$(dirname "$0")/bash-spec.sh"

describe "mise-non-place CLI tasks" && {

  export TEST_DIR="/tmp/mnp-test-suite"
  export MNP_DIR="$(cd "$(dirname "$0")/.." && pwd)"
  export MNP_NAME="$(basename "$MNP_DIR")"
  
  # Setup
  rm -rf "$TEST_DIR"
  mkdir -p "$TEST_DIR/dummy-project"
  git -C "$TEST_DIR/dummy-project" init -q
  echo "test" > "$TEST_DIR/dummy-project/test.txt"
  git -C "$TEST_DIR/dummy-project" add test.txt
  git -C "$TEST_DIR/dummy-project" commit -qm "init"
  
  context "when injecting with pick + worktree:add" && {
    
    # Pick the project then add worktree
    cd "$MNP_DIR"
    mise run pick "$TEST_DIR/dummy-project" > /dev/null
    
    # Add worktree with defaults (2 newlines for prompts)
    printf "\n\n" | mise run worktree:add
    RESULT=$?

    it "succeeds with exit code 0" && {
      expect "$RESULT" to_be 0
    }

    it "creates the hidden .$MNP_NAME clone" && {
      [[ -d "$TEST_DIR/dummy-project/.$MNP_NAME/.git" ]]
      should_succeed
    }

    it "creates the visible mise/ worktree" && {
      [[ -d "$TEST_DIR/dummy-project/mise" ]]
      should_succeed
    }

    it "adds both folders to the target exclude file" && {
      grep -q "^.$MNP_NAME/$" "$TEST_DIR/dummy-project/.git/info/exclude"
      should_succeed

      grep -q "^mise/$" "$TEST_DIR/dummy-project/.git/info/exclude"
      should_succeed
    }
    
    it "stores picked value in git config" && {
      PICKED="$(git config --local --get mise-non-place.picked)"
      [[ "$PICKED" == "$TEST_DIR/dummy-project" ]]
      should_succeed
    }
  }
  
  context "when adding a second worktree with encoding" && {
    
    # Add a worktree with a leading dot (needs encoding)
    mise run worktree:add .config
    RESULT=$?

    it "succeeds" && {
      expect "$RESULT" to_be 0
    }

    it "creates the .config worktree" && {
      [[ -d "$TEST_DIR/dummy-project/.config" ]]
      should_succeed
    }

    it "creates encoded branch" && {
      git -C "$TEST_DIR/dummy-project/.$MNP_NAME" branch | grep -q "dummy-project/%2Econfig"
      should_succeed
    }
  }
  
  context "when removing a specific worktree" && {
    
    # Remove just the .config worktree
    mise run worktree:remove .config
    RESULT=$?

    it "succeeds" && {
      expect "$RESULT" to_be 0
    }

    it "removes the .config worktree" && {
      [[ ! -d "$TEST_DIR/dummy-project/.config" ]]
      should_succeed
    }

    it "keeps the mise worktree" && {
      [[ -d "$TEST_DIR/dummy-project/mise" ]]
      should_succeed
    }

    it "keeps .$MNP_NAME" && {
      [[ -d "$TEST_DIR/dummy-project/.$MNP_NAME" ]]
      should_succeed
    }
  }
  
  context "when removing with remove-all" && {
    
    # Pick then remove-all
    cd "$MNP_DIR"
    mise run pick "$TEST_DIR/dummy-project" > /dev/null
    echo "1" | MISE_YES=1 mise run remove-all > /dev/null 2>&1
    RESULT=$?

    it "succeeds with exit code 0" && {
      expect "$RESULT" to_be 0
    }

    it "removes the worktree folder" && {
      [[ ! -d "$TEST_DIR/dummy-project/mise" ]]
      should_succeed
    }

    it "removes the .$MNP_NAME clone" && {
      [[ ! -d "$TEST_DIR/dummy-project/.$MNP_NAME" ]]
      should_succeed
    }

    it "cleans the exclude file" && {
      grep -q "^.$MNP_NAME/$" "$TEST_DIR/dummy-project/.git/info/exclude"
      should_fail

      grep -q "^mise/$" "$TEST_DIR/dummy-project/.git/info/exclude"
      should_fail
    }
  }
}
