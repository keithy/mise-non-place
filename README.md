# mise-non-place

[![Test](https://github.com/keithy/mise-non-place/actions/workflows/test.yml/badge.svg)](https://github.com/keithy/mise-non-place/actions/workflows/test.yml)

*Take your Mise-en-place with you anywhere and everywhere; a re-usable pattern.*

Add [mise](https://mise.jdx.dev/) support to any project that doesn't natively have it, without modifying either the local or upstream  repository.

## Problem

You want to use `mise` to manage tasks, tools, and environments for a project, but you cannot (or don't want to) commit a `.mise.toml`, `.mise/` or `mise` directory to the target repository. (e.g. perhaps  it's a third-party project or doesn't allow forking).

## Solution

This tool is a standalone repository for your local `mise` configurations that injects itself into target projects using `git worktree`. The configuration stays completely invisible to the target project.

### The Magic of Git Worktrees

1. You start by cloning this repository anywhere on your machine.
2. You `pick` a target project to work on (e.g. `my-project`).
2. The `new:<something>` tasks clone this instance into a target project as a hidden `.mise-non-place/` directory (anchored to the `main` branch).
3. It then spawns a visible `mise/` directory inside the target project using `git worktree`, checked out to a project-specific branch (e.g., `mise/my-project`).
4. Both directories are automatically added to the target project's `.git/info/exclude`, making them completely invisible to `git`.

This gives you a dedicated workspace for your configuration that seamlessly blends into any codebase, while sharing a single git database across all your projects!

### Reusable Pattern

This same approach works for other shared resources aka:
- `migrations-non-place` - database migrations for multiple projects
- `scripts-non-place` - shared scripts across projects
- `config-non-place` - any configuration you want to share

## Requirements

- git with worktree support
- mise installed

## Setup

Since you will be storing your own project-specific configurations, start by **forking** the `keithy/mise-non-place` repository on GitHub.

Then, clone your fork to your machine so you can explore it and use its tasks:

```bash
git clone https://github.com/yourusername/mise-non-place.git
cd mise-non-place
mise tasks ls
mise run
```

## Usage

From your `mise-non-place` clone, you can inject mise configurations into any project.

### Pick a project

First, pick the target project:

```bash
mise run pick /path/to/project
# or interactively:
mise run pick /search/dir
```

This stores the selection in git config (`mise-non-place.picked`).

### Add a worktree

Then add worktrees to that project:

```bash
# Interactive (prompts for worktree name and template)
mise run worktree:add

# With args: <worktree_name> [<template>]
mise run worktree:add scripts
mise run worktree:add scripts template/empty
```

This will:
1. Clone `.mise-non-place/` into the target project (if not already present)
2. Create a worktree at `<worktree_name>/`
3. Create a branch `<project>/<worktree_name>` from the template
4. Trust the mise configuration
5. Add both directories to `.git/info/exclude`
6. Update the new `.mise-non-place` such that `pick` points to the new project

### Status

Check what's configured:

```bash
mise run status
```

Shows:
```
Picked: /path/to/project

Worktrees:
  /path/to/project/.mise-non-place -> main
  /path/to/project/mise -> project_name/mise
```

### Working with your configurations

Once injected, `cd` into the worktree:

```bash
cd /path/to/target/project/mise
# Add tasks or edit config.toml
git add .mise/config.toml
git commit -m "Add new build tasks"
git push origin HEAD
```

### Remove from a project

⚠️ **Warning: Backup unpushed changes first!**

```bash
mise run remove
```

This safely unlinks worktrees and cleans up `.git/info/exclude`.

## Creating Custom Templates

Create a branch for your template:

```bash
# From your mise-non-place clone
git checkout -b template/jdk
# Add your config to .mise/config.toml
git add .mise/config.toml
git commit -m "Add JDK template"
git push origin template/jdk
git checkout main
```

Then use it when creating worktrees:

```bash
mise run worktree:new mise template/jdk
```

### Specialized Tasks

For specialized setups, create task files in `.mise/tasks/worktree/`:

```bash
# .mise/tasks/worktree/mise-go
mise run worktree:new mise template/mise-go
```

Run with `mise run worktree:mise-go`.