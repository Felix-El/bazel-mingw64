""" MinGW64 Toolchain File """

load("@bazel_tools//tools/build_defs/cc:action_names.bzl", "ACTION_NAMES")
load(
    "@bazel_tools//tools/cpp:cc_toolchain_config_lib.bzl",
    "action_config",
    "artifact_name_pattern",
    "feature",
    "flag_group",
    "flag_set",
    "tool",
    "tool_path",
    "variable_with_value",
)
load("@rules_cc//cc:defs.bzl", "cc_toolchain")

all_link_actions = [
    ACTION_NAMES.cpp_link_executable,
    # ACTION_NAMES.cpp_link_static_library,
    ACTION_NAMES.cpp_link_dynamic_library,
    ACTION_NAMES.cpp_link_nodeps_dynamic_library,
]

mingw_arch_map = { "x86_32": "i686", "x86_64": "x86_64" }

def _toolchain_config_info_impl(ctx):
    mingw_arch = mingw_arch_map[ctx.attr.architecture]
    return cc_common.create_cc_toolchain_config_info(
        ctx = ctx,
        features = [
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
                                    "-lm"
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
            "/usr/lib/gcc/{}-w64-mingw32/10-posix/include".format(mingw_arch),
            "/usr/lib/gcc/{}-w64-mingw32/10-posix/include-fixed".format(mingw_arch),
            "/usr/share/mingw-w64/include",
        ],
        toolchain_identifier = "local",     # Seen in tutorial but is it appropriate here?
        host_system_name = "local",         # Same here.
        target_system_name = "{}-w64-mingw32".format(mingw_arch),
        target_cpu = ctx.attr.architecture,
        target_libc = "unknown",
        compiler = "{}-w64-mingw32-g++-posix".format(mingw_arch),
        abi_version = "unknown",
        abi_libc_version = "unknown",
        tool_paths = [
            tool_path(
                name = "gcc",
                path = "/usr/bin/{}-w64-mingw32-gcc-posix".format(mingw_arch),
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
                path = "/usr/bin/{}-w64-mingw32-cpp-posix".format(mingw_arch),
            ),
            tool_path(
                name = "gcov",
                path = "/usr/bin/{}-w64-mingw32-gcov-posix".format(mingw_arch),
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
        ]
    )

mingw_toolchain_config = rule(
    implementation = _toolchain_config_info_impl,
    attrs = {
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

def mingw_toolchain(name, compiler_components, architecture):
    """Define a MINGW toolchain

    Args:
      name: Name of the toolchain
      compiler_components: Components
      architecture: CPU of the toolchain
    """

    toolchain_config = name + "_config"
    mingw_arch = mingw_arch_map[architecture]
    toolchain_id = "{}-w64-mingw32".format(mingw_arch)

    mingw_toolchain_config(
        name = toolchain_config,
        architecture = architecture,
        toolchain_identifier = toolchain_id,
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

    native.toolchain(
        name = "-".join(["cc-toolchain", architecture]),
        target_compatible_with = [
            "@platforms//cpu:{}".format(architecture),
            "@platforms//os:windows",
        ],
        toolchain = ":" + name,
        toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
    )

