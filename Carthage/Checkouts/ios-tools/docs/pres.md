autoscale: true
build-lists: true

# Framework Tools and Workflows

---

## Problems
- Cocoapods owns the workspace and project
- Internal spec repo is a burden
- Podspecs are a burden
- Submodules have a bad reputation

---

## Goals
- Support pre-built frameworks
- Easily flip a dependency into development mode
- Push new code to dependency and tag (if appropriate)
- Easily adjust project to point to new version of the dependency

---

## Proposal

---

## Carthage
- Use Carthage to build dependencies
- Carthage supports pre-build frameworks (with github enterprise)
- Custom script to ease the copy-frameworks phase

---

## mkworkspace
- Workspaces are left to the developer to use as they see fit
 - don't check them in
- `mkworkspace` will automatically generate a workspace with dependencies
- Adjust new workspace as you see fit

---

## carttool
- Tool to easily checkout a dependency
 - Clones repo based on `Cartfile.resolved`
 - Creates a backup of previous checkout
 - Optionally supply a destination folder
- Edit dependency and push
- Update local `Cartfile` to point to new hash/tag (unless it's using a branch)

---

## Concerns
- How well will it work with projects already containing frameworks in the same repo? (DNA)
- Requires good documentation and training
- Try building DNA's external dependencies with carthage and see if they break
- Combine mkworkspace and carttool ? 
- Possible to lock dependencies not checked out (like Cocoapods)
- How to update Cartfile.resolved (`carthage update` will clobber the dev-mode checkout -- maybe encourage using carttool with custom folder?)

