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

def _setup(repository_ctx):
    project_dir = repository_ctx.path(repository_ctx.attr.project).dirname

    # repository_ctx.symlink("//:__pypackages__", repository_ctx.path("../../__pypackages__"))
    repository_ctx.symlink(repository_ctx.attr.project, repository_ctx.path("../../pyproject.toml"))
    repository_ctx.symlink(repository_ctx.attr.lock, repository_ctx.path("../../pdm.lock"))
    repository_ctx.symlink(repository_ctx.attr.config, repository_ctx.path("../../.pdm.toml"))

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
            allow_single_file = True,
            doc = "The label of the pyproject.toml file.",
            default = "@//:pyproject.toml",
        ),
        "lock": attr.label(
            allow_single_file = True,
            doc = "The label of the pdm.lock file.",
            default = "@//:pdm.lock",
        ),
        "config": attr.label(
            allow_single_file = True,
            doc = "The label of the .pdm.toml config file.",
            default = "@//:.pdm.toml",
        ),
    },
    implementation = _pdm_environment_impl,
)
