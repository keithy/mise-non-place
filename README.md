# mise-non-place

Add [mise](https://mise.jdx.dev/) support to any project that doesn't natively have it, without modifying the target repository.

## Problem

You want to use `mise` to manage tasks, tools, and environments for a project, but you cannot (or don't want to) commit a `.mise.toml` or `.mise/` directory to the target repository (e.g. because it's a third-party project or doesn't allow forking).

## Solution

This tool is a standalone repository for your local `mise` configurations that injects itself into target projects using `git worktree`. The configuration stays completely invisible to the target project.

### The Magic of Git Worktrees

1. You start by cloning this repository anywhere on your machine.
2. The `new` task clones that instance into a target project as a hidden `.mise-non-place/` directory (anchored to the `main` branch).
3. It then spawns a visible `mise/` directory inside the target project using `git worktree`, checked out to a project-specific branch (e.g., `mise/my-project`).
4. Both directories are automatically added to the target project's `.git/info/exclude`, making them completely invisible to git.

This gives you a dedicated workspace for your configuration that seamlessly blends into any codebase, while sharing a single git database across all your projects!

### Reusable Pattern

This same approach works for other shared resources:
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
```

## Usage

From your `mise-non-place` clone, you can safely and instantly inject a `mise` environment into any other project!

### Add to a project

From your `mise-non-place` clone, run one of the `new:*` tasks and point it at the directory containing your target projects (e.g., `~/code`):

```bash
mise run new:mise-go ~/code
# or
mise run new:mise-rust ~/code
# or
mise run new:empty ~/code
```

This will:
1. Scan the provided directory (`~/code`) for other git repositories.
2. Prompt you to select a target project.
3. Automatically clone `.mise-non-place/` into the target project.
4. Create a specific branch for that project (e.g. `mise/<project>`) explicitly branched from the template (e.g. `template/mise-go`).
5. Create a visible worktree linked to that branch (e.g. `mise/`).
6. Automatically trust the generated `mise` configurations.
7. Auto-hide the directories in the target project's `.git/info/exclude`.

*Note: Because every injected project contains a full clone in `.mise-non-place/`, you can run `mise run new:*` from inside any seeded project to infect new projects!*

### Working with your configurations

Once injected, simply `cd` into the visible `mise/` folder inside your target project.

Because this folder is a standard git worktree connected to its own branch (`mise/<project>`), you can manage it exactly like any other git repository:

```bash
cd /path/to/target/project/mise
# Add tasks or edit config.toml
git add .mise/config.toml
git commit -m "Add new build tasks for my project"
git push origin HEAD
```

Any changes you commit here are safely isolated to this specific project's configuration branch in your fork!

### Remove from a project

⚠️ **Warning: Removal is destructive to unpushed changes!** 
Because the `.mise-non-place` directory in your target project is a full clone, deleting it will instantly destroy any commits you made in the `mise/` worktree that you haven't yet pushed to your central repository (using `git push origin HEAD`).

You can run the `remove` task from anywhere. If you run it from *inside* the project you are trying to clean up, it will safely unlink the worktrees but leave the hidden `.mise-non-place/` clone intact (since a script cannot delete the directory it is actively running from).

To completely remove the clone as well, simply run the command from another location:

```bash
cd /path/to/another/project/.mise-non-place
mise run remove /path/to/the/target/project
```

As long as your changes were pushed, this safely unlinks the worktree, removes the hidden directories, and cleans up the `.git/info/exclude`. Your configuration branches remain safely untouched in your central repository!

## Creating Custom Templates

`mise-non-place` uses a pure branch-based template system.

To create a new template (e.g. for Python):
1. Create a branch named `template/mise-python`.
2. Add your pure, project-specific configuration to it (e.g., `.mise/config.toml`, `.mise.toml`).
3. Push it to your central repository.
4. Add a new task in your main branch's `config.toml`:

```toml
[tasks."new:mise-python"]
description = "Inject the Python template"
run = "mise run _inject \"${1:-../..}\" \"template/mise-python\" \"mise\""
```