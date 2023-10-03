# MinGW64 Toolchain for Bazel

__For learning - not for production__

## About

In this project, we register a custom toolchain to be able to cross-compile the
project to Windows using the MinGW64 project (which is a GCC) running on Linux
x86/x64 but targetting Windows x86/x64.

The example project to build with that toolchain is one shared library used
by one executable. This is tailored to Ubuntu 22.04 with MinGW64 version 10.

## Limitation

Bazel needs to be built from [my fork](https://github.com/Felix-El/bazel) where a
bug is fixed which otherwise causes linking to fail in upstream Bazel.

## Building

You need to install MinGW64 (once):

```bash
sudo apt install gcc-mingw-w64 g++-mingw-w64
```

Then you can build for `x86_64`,

```bash
bazel build --config=wine64 //example/greeter
```

or for `i686`

```bash
bazel build --config=wine32 //example/greeter
```

The configs imply `--platforms=//toolchain:mingw-x86_64-win32` and
`--platforms=//toolchain:mingw-x86_32-win32`, respectively.
As those are only for testing, there are no `-posix` equivalents.

## Running

You need to install Wine (once):

```bash
sudo apt install --no-install-recommends wine32 # for i686
sudo apt install --no-install-recommends wine64 # for x86_64
```

Then you can run for `x86_64`,

```bash
bazel run --config=wine64 //example/greeter Felix
```

or for `i686`

```bash
bazel run --config=wine32 //example/greeter Felix
```
