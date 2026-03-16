# mise-non-place

Add mise support to any project that doesn't have it.

## Problem

You want to use [mise](https://mise.jdx.dev/) with a non mise-savvy project.

## Solution

This tool is a **separate repository** for your local mise configuration that
can be added to any project as a worktree.

### Why separate repo?

- Some projects don't allow forking
- Manage mise completely outside the main repository of a project
- Share mise between multiple projects
- Easy to backup/export

### Reusable Pattern

This same approach works for other shared resources:
- `migrations-non-place` - database migrations for multiple projects
- `scripts-non-place` - shared scripts across projects
- `config-non-place` - any configuration you want to share

The pattern: **one repo, multiple projects, worktree integration**.

### How it works

1. [clone] this repo to `<project>/.mise-non-place`
2. [new] Create a branch in `mise-non-place` for this project.
3. Add as worktree to your project: `git worktree add mise .mise-non-place`
4. Hide from git: add `.mise-non-place/` to `.git/info/exclude`
5. Your local config lives in `.mise-non-place/`, invisible to the project

## Usage

```bash
cd .mise-non-place
mise run mise-non-place:new
mise run mise-non-place:worktree
mise run mise-non-place:hide
```

## What you need

## Requirements

- git with worktree support
- mise installed

## Setup

```bash
# Clone somewhere (e.g., your home directory)
git clone https://github.com/yourusername/mise-non-place.git ~/.mise-non-place

# Add as worktree to your project (hidden directory)
git worktree add .mise-non-place ~/.mise-non-place

# Hide from git
echo ".mise-non-place/" >> .git/info/exclude
```
