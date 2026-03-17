# The "Sovereign Developer": mise-en-place + mise-non-place + worktrees

### The Scenario

You’re a hotshot dev, you love `mise-en-place`; it is your "utility belt" (scripts, linters, specialized CLIs) that makes you fast. The client’s project, its big, lots of repos, and their environment is bare-bones, they use a "dumb" Git workflow (constant checkouts/stashing), and they won't let you modify the project's tooling in any meaningful way.

**This is how you maintain your edge without asking for permission.**

---

## 1. The Utility Belt (mise-non-place)

When you are at the mercy of the project's tooling, they may have `.mise.toml`. or you can add one locally (unmanaged). If they don't have the tools you need, what to do?

```
$> cd /code
$> gh clone my-boss/their-project
$> gh repo fork keithy/mise-non-place --clone
$> cd mise-non-place 

$> mise run pick ../their-project
$> mise run worktree:add mise template/mise-go-tools
$> mise run worktree:add my-migrations template/empty

$> mise run pick ../project-refactor
$> mise run worktree:add mise template/mise-go-tools

/code 
├── mise-en-place       <-- initial fork
├── their-project/
│   ├── .mise-non-place <-- Hidden parasitic toolbelt manager (toolbelt branch main) 
│   ├── mise/           <-- Your Toolbelt      (worktree toolbelt branch their-project/mise) 
│   ├── my-migrations/  <-- Your Customisation (worktree toolbelt branch their-project/my-migrations)
│   └── src/            # their project: mise finds ./mise/tasks/go-build etc.
│
├── project-two/           <== (another project OR working-tree branch)
│   ├── .mise-non-place    <-- Another hidden parasitic toolbelt manager clone (branch main) 
│   ├── mise/              <-- Your Toolbelt again (worktree-branch project-two/mise) 
│   │   └── mise.test.toml <-- Test environment config
│   ├── .miserc.toml       <-- Local tweak to set MISE_ENV=test
│   └── src/            # their project under test
```

**The Move:** You bring your own environment using **mise-non-place**. You pull your specialized `mise-go-tools` or `web-stack` branch from your personal `mise-non-place` repo into a local directory.

From there you can parasitically infect any projects you wish to work on, and add your additions
to them, as a visible-to-you worktree that is excluded from their git upstream.

**The Result:** * **Zero Footprint:** You haven't touched their version-controlled files, not even `gitignore`.
* **Total Power:** You have your version of the compiler, your preferred debugger, and your custom task runners active in *their* workspace.
* **Portable:** This isn't a global "system" install that breaks other projects; it is scoped specifically to this mission.
* **Self-Contained:** Each project gets a copy of your toolbelt, it is safer that way.

## 1b. Second project

Repeat the process for a second project, each `<project>/mise` folder gets its own `branch` managed in its own `.mise-non-place` clone. Not only are your tools isolated from the projects scm, but also from each other.

unless...

## 2. Phase Two: The Laboratory (Git Worktrees)
Imagine that you need to perform a massive refactoring, but you need to keep the stable code running in the background to compare outputs.

**The Problem:** Once upon a time, before` git` spoiled everything, decent, lovely, understandable and easy to use SCM tools (Bazaar, Mercurial), would checkout branches into separate folders.
Standard Git `checkout` is destructive, and it wipes out a current state to show you another.

**The Move:**, **Git Worktrees** are the `git` way of admitting that they were wrong all along! You spawn a second physical folder for your refactoring task:

```
$> cd their-project && git worktree add ../project-refactor feature/ABC-1_branch
```

**The Result:** * **Side-by-Side Execution:** You have the "Old" code in Folder A and the "New" code in Folder B, side by side, and you can easily add a copy of your toolbelt, TO THE PARENT FOLDER OF BOTH! 

```
$> cd their-project/.mise-non-place
$> mise run pick ..
$> mise run worktree:add ../mise their-project/mise # two magic dots
```

* **Persistent Tooling:** Because your `mise-non-place` folder exists in your project structure, **your utility belt is present in the parent folder.** mise scans the parent heirarchy looking for tools so You didn't have to set up your environment twice.

## 3. Phase Three: Branch-Specific Evolution
What if the refactor requires a different language version (e.g., migrating from Node 18 to Node 22)?

**The Move:** You drop a local `.mise.toml` into the `refactor/` worktree. 

**The Result:** * **Folder A (Stable):** Still running Node 18 + your `mise-non-place` utility belt.
* **Folder B (Refactor):** Running Node 22 + the **exact same** `mise-non-place` utility belt.
* **The Outcome:** You are testing the future without breaking the present, all while keeping your personal "pro" tools consistent across both environments.

---

## Summary: The Competitive Advantage

| Feature | The "Average" Dev | The Sovereign Dev (You) |
| :--- | :--- | :--- |
| **Tooling** | Uses whatever is in the repo. | Brings a custom "Non-Place" belt. |
| **Context Switching** | `git stash` & `checkout` (Slow). | `cd ../refactor` (Instant). |
| **Environment** | Fragile global installs. | Isolated, versioned, and portable. |
| **Visibility** | One branch at a time. | Side-by-side comparison. |

---

### How to Tweak This
* **The "Infiltrator" angle:** Focus more on how `mise-non-place` allows you to work in "hostile" repos without changing their files. The `main+234+123` workflow.
* **The "Sensible SCM" angle:** Emphasize how this fixes Git's single-directory limitation to match better systems like Mercurial/Bazaar.