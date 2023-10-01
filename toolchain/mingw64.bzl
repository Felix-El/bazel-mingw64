"""MinGW64 Toolchain File

Use `mingw_toolchain()` to register a toolchain and a matching platform.
Two architectures, `x86_64` and `x86_32` are supported (@platforms//cpu)
and two threading models, `win32` and `posix` (@bazel-mingw64//threads).
"""

load("@bazel_tools//tools/build_defs/cc:action_names.bzl", "ACTION_NAMES")
load(
    "@bazel_tools//tools/cpp:cc_toolchain_config_lib.bzl",
    "artifact_name_pattern",
    "feature",
    "flag_group",
    "flag_set",
    "tool_path",
)
load("@rules_cc//cc:defs.bzl", "cc_toolchain")

all_link_actions = [
    ACTION_NAMES.cpp_link_executable,
    # ACTION_NAMES.cpp_link_static_library,
    ACTION_NAMES.cpp_link_dynamic_library,
    ACTION_NAMES.cpp_link_nodeps_dynamic_library,
]

mingw_arch_map = {"x86_32": "i686", "x86_64": "x86_64"}

def _toolchain_config_info_impl(ctx):
    mingw_arch = mingw_arch_map[ctx.attr.architecture]
    threads = ctx.attr.threads

    return cc_common.create_cc_toolchain_config_info(
        ctx = ctx,
        features = [
            feature(
                name = "copy_dynamic_libraries_to_binary",
                enabled = True,
            ),
            feature(
                name = "supports_dynamic_linker",
                enabled = True,
            ),
            feature(
                name = "supports_interface_shared_libraries",
                enabled = True,
            ),
            feature(
                name = "default_linker_flags",
                enabled = True,
                flag_sets = [
                    flag_set(
                        actions = all_link_actions,
                        flag_groups = ([
                            flag_group(
                                flags = [
                                    "-lstdc++",
                                    "-lm",
                                ],
                            ),
                        ]),
                    ),
                ],
            ),
        ],
        artifact_name_patterns = [
            artifact_name_pattern(
                category_name = "executable",
                prefix = "",
                extension = ".exe",
            ),
            artifact_name_pattern(
                category_name = "static_library",
                prefix = "lib",
                extension = ".a",
            ),
            artifact_name_pattern(
                category_name = "dynamic_library",
                prefix = "lib",
                extension = ".dll",
            ),
            artifact_name_pattern(
                category_name = "interface_library",
                prefix = "",
                extension = ".ifso",
            ),
        ],
        cxx_builtin_include_directories = [
            "/usr/lib/gcc/{}-w64-mingw32/10-{}/include".format(mingw_arch, threads),
            "/usr/lib/gcc/{}-w64-mingw32/10-{}/include-fixed".format(mingw_arch, threads),
            "/usr/share/mingw-w64/include",
        ],
        toolchain_identifier = "local",  # Seen in tutorial but is it appropriate here?
        host_system_name = "local",  # Same here.
        target_system_name = "{}-w64-mingw32".format(mingw_arch),
        target_cpu = ctx.attr.architecture,
        target_libc = "unknown",
        compiler = "{}-w64-mingw32-g++-{}".format(mingw_arch, threads),
        abi_version = "unknown",
        abi_libc_version = "unknown",
        tool_paths = [
            tool_path(
                name = "gcc",
                path = "/usr/bin/{}-w64-mingw32-gcc-{}".format(mingw_arch, threads),
            ),
            tool_path(
                name = "ld",
                path = "/usr/bin/{}-w64-mingw32-ld".format(mingw_arch),
            ),
            tool_path(
                name = "ar",
                path = "/usr/bin/{}-w64-mingw32-ar".format(mingw_arch),
            ),
            tool_path(
                name = "cpp",
                path = "/usr/bin/{}-w64-mingw32-cpp-{}".format(mingw_arch, threads),
            ),
            tool_path(
                name = "gcov",
                path = "/usr/bin/{}-w64-mingw32-gcov-{}".format(mingw_arch, threads),
            ),
            tool_path(
                name = "nm",
                path = "/usr/bin/{}-w64-mingw32-nm".format(mingw_arch),
            ),
            tool_path(
                name = "objdump",
                path = "/usr/bin/{}-w64-mingw32-objdump".format(mingw_arch),
            ),
            tool_path(
                name = "strip",
                path = "/usr/bin/{}-w64-mingw32-strip".format(mingw_arch),
            ),
        ],
    )

mingw_toolchain_config = rule(
    implementation = _toolchain_config_info_impl,
    attrs = {
        "threads": attr.string(
            default = "win32",
            doc = "Threading model",
            mandatory = False,
            values = [
                "win32",
                "posix",
            ],
        ),
        "architecture": attr.string(
            default = "x86_64",
            doc = "System architecture",
            mandatory = False,
            values = [
                "x86_64",
                "x86_32",
            ],
        ),
        "toolchain_identifier": attr.string(
            mandatory = True,
            doc = "Indentifier used by the toolchain, this should be consistent with the cc_toolchain rule attribute",
        ),
    },
    provides = [CcToolchainConfigInfo],
)

def mingw_toolchain(name, compiler_components, architecture, threads):
    """Define a MINGW toolchain

    Args:
      name: Name of the toolchain
      compiler_components: Components
      architecture: CPU of the toolchain
      threads: Threading model
    """

    toolchain_config = name + "_config"
    mingw_arch = mingw_arch_map[architecture]
    toolchain_id = "{}-w64-mingw32-{}".format(mingw_arch, threads)

    mingw_toolchain_config(
        name = toolchain_config,
        architecture = architecture,
        toolchain_identifier = toolchain_id,
        threads = threads,
    )

    cc_toolchain(
        name = name,
        all_files = compiler_components,
        compiler_files = compiler_components,
        dwp_files = compiler_components,
        linker_files = compiler_components,
        objcopy_files = compiler_components,
        strip_files = compiler_components,
        as_files = compiler_components,
        ar_files = compiler_components,
        supports_param_files = 0,
        toolchain_config = ":" + toolchain_config,
        toolchain_identifier = toolchain_id,
    )

    constraints = [
        "@platforms//os:windows",
        "@platforms//cpu:{}".format(architecture),
        "@bazel-mingw64//threads:{}".format(threads),
    ]

    native.toolchain(
        name = "cc-toolchain-{}-{}".format(architecture, threads),
        target_compatible_with = constraints,
        toolchain = ":" + name,
        toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
    )

    native.platform(
        name = "mingw-{}-{}".format(architecture, threads),
        constraint_values = constraints,
    )
