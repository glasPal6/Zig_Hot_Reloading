# Hot Reloading in zid

Hot Reloading is useful in projects where quick iteration is required, such as in game dev where you want to quickly see the outcome of your changes without having to recompile everything.

The purpose of this is to build a basic Hot Reloading example with raylib, but it can be used in any project. It is just easier to see the library change with a GUI.

Checkout [Hot reloading in C](https://github.com/glasPal6/C_Hot_Reloading) for a C version.

## Build

To build the whole project run:
```
zig build -Dbuild_plugin=false
```
This will make the plugin library and the main executable.

To build just the plugin run:
```
zig build -Dbuild_plugin=true
```
which will reload the plugin into the main executable that is running. In this case, ```plug.c``` is reloaded by pressing the R key in the main executable.

Hot reloading can be enabled with `-Ddisable_honreload=true`.

# Basic background theory

In C and Zig there are static and dynamic libraries. A static library is a library that is linked into the project and the code is included in the binary. We cannot change something in the binary while it is runnig so we cannot us static libraries for this use case. 

A dynamic library is a library that is linked at runtime and loads the functions into a lookup table that that is used at runtime. All we do is rebuild the table with the updated functions and presto, we have hot reloading.

# TODO

- Make hotreload.zig write out the loading of the modules at runtime.
- Make hotreloading an option.

