# MinGW64 Toolchain for Bazel

__For learning - not for production__


## About

In this project, we register a custom toolchain to be able to cross-compile the
project to Windows using the MinGW64 project which is a GCC running on
Linux x86/x64 but targetting Windows x86/x64.

The example project to build with that toolchain is one shared library used
by one executable.

This is tailored to Ubuntu 22.04 with MinGW64 version 10.

## Building

You need to install MinGW64 (once):

```bash
sudo apt install gcc-mingw-w64 g++-mingw-w64
```

Then you can build for `x86_64`,

```bash
bazel build --platforms=//toolchain:mingw_x86_64 //greeter
```

or for `i686`

```bash
bazel build --platforms=//toolchain:mingw_x86_32 //greeter
```

## Running

You need to install Wine (once):

```bash
sudo apt install --no-install-recommends wine32 # for i686
sudo apt install --no-install-recommends wine64 # for x86_64
```

Then you can run for `x86_64`,

```bash
WINEPATH="/usr/x86_64-w64-mingw32/lib;/usr/lib/gcc/x86_64-w64-mingw32/10-posix;bazel-bin/libgreet" wine64-stable bazel-bin/greeter/greeter.exe
```

or for `i686`

```bash
WINEPATH="/usr/i686-w64-mingw32/lib;/usr/lib/gcc/i686-w64-mingw32/10-posix;bazel-bin/libgreet" wine32-stable bazel-bin/greeter/greeter.exe
```