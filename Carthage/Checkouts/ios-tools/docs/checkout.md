# Command line tool to checkout a dependency framework

The name of the tool is yet to be determined. It is currently called `checkout`.

## Usage
`checkout <Dependency> [--rescue]`

Where `<Dependency>` is a dependency at `Carthage/Checkouts/<Dependency>`.

This command must be executed from the root of the project (the folder containing the `Cartfile` and `Cartfile.resolved`)

## Options
`--rescue`
Move the current code out of the way, clone the dependency, then copy the current code over the top of the cloned repo. This can be used to "rescue" a situation where you started to modify a dependency before realizing it wasn't checked out in development mode. 

## How it works
The tool will look for the `<Dependency>` in `Cartfile.resolved`. The specific tag or hash referenced in `Cartfile.resolved` will be used. It will clone the repo and checkout the appropriate hash/tag. If `--rescue` is requested, it will move the old project aside before cloning the project, and then do a recursive copy of the old project over the newly cloned project.


