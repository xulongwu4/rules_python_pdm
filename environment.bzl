"""
Pdm Environment Repository

Designed to manage the virtual environment using Pdm and export a further repository to interact with it.
"""

BUILD_TMPL = """\
load("@rules_python//python:defs.bzl", "py_runtime", "py_runtime_pair")

py_runtime(
    name = "pdm_runtime",
    files = ["pdm-python-wrapper"],
    interpreter = "pdm-python-wrapper",
    python_version = "PY3"
)

py_runtime_pair(
    name = "pdm_runtime_pair",
    py3_runtime = ":pdm_runtime",
    visibility = ["//visibility:public"],
)

toolchain(
    name = "pdm_toolchain",
    toolchain = ":pdm_runtime_pair",
    toolchain_type = "@rules_python//python:toolchain_type",
)
"""

PDM_WRAPPER = """\
#!/usr/bin/env sh

pdm run python "$@"
"""

SETUP_SCRIPT = """\
#!/usr/bin/env sh

BAZEL_WORKSPACE=$1
BAZEL_OUTPUT_BASE=$2

for file in __pypackages__ pyproject.toml pdm.lock .pdm.toml; do
    [ -e "$BAZEL_WORKSPACE"/"$file" ] && ln -sf "$BAZEL_WORKSPACE"/"$file" "$BAZEL_OUTPUT_BASE"/"$file"
done
"""

def _setup(repository_ctx):
    repository_ctx.file(
        "setup-pdm",
        SETUP_SCRIPT,
        executable = True,
    )
    script = repository_ctx.path("setup-pdm")
    project_dir = repository_ctx.path(repository_ctx.attr.project).dirname
    result = repository_ctx.execute([script, str(project_dir), str(repository_ctx.path("../.."))])
    if result.return_code:
        fail("Failed to set up symlinks for pdm: {}".format(result.stderr))

def _symlink_packages(repository_ctx):
    project_dir = repository_ctx.path(repository_ctx.attr.project).dirname
    repository_ctx.symlink(repository_ctx.path(str(project_dir) + "/__pypackages__"), repository_ctx.path("__pypackages__"))

def _render_files(repository_ctx):
    repository_ctx.file(
        "BUILD",
        BUILD_TMPL,
    )

    repository_ctx.file(
        "pdm-python-wrapper",
        PDM_WRAPPER,
        executable = True,
    )

def _pdm_environment_impl(repository_ctx):
    _setup(repository_ctx)
    _render_files(repository_ctx)

pdm_environment = repository_rule(
    attrs = {
        "project": attr.label(
            # mandatory = True,
            allow_single_file = True,
            doc = "The label of the pyproject.toml file.",
            default = "//:pyproject.toml",
        ),
        "lock": attr.label(
            # mandatory = True,
            allow_single_file = True,
            doc = "The label of the pdm.lock file.",
            default = "//:pdm.lock",
        ),
        "config": attr.label(
            # mandatory = True,
            allow_single_file = True,
            doc = "The label of the .pdm.toml config file.",
            default = "//:.pdm.toml",
        ),
    },
    implementation = _pdm_environment_impl,
)
