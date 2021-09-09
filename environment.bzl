"""
Pdm Environment Repository

Designed to manage the virtual environment using Pdm and export a further repository to interact with it.
"""

def _setup(repository_ctx):
    pass

def _symlink_packages(repository_ctx):
    project_dir = repository_ctx.path(repository_ctx.attr.project).dirname
    repository_ctx.symlink(repository_ctx.path(str(project_dir) + "/__pypackages__"), repository_ctx.path("__pypackages__"))

def _symlink_project_files(repository_ctx):
    repository_ctx.symlink(
        repository_ctx.attr.project,
        repository_ctx.path("pyproject.toml"),
    )
    repository_ctx.symlink(
        repository_ctx.attr.lock,
        repository_ctx.path("pdm.lock"),
    )
    repository_ctx.symlink(
        repository_ctx.attr.config,
        repository_ctx.path(".pdm.toml"),
    )

def _render_templates(repository_ctx):
    environment_path = str(repository_ctx.path(".venv").dirname)
    venv_path = str(repository_ctx.path(".venv"))

    repository_ctx.template(
        "BUILD",
        Label("@rules_python_pdm//:BUILD"),
    )

def _pdm_environment_impl(repository_ctx):
    # managed_root = repository_ctx.path(repository_ctx.attr.project).dirname
    # repository_ctx.execute(
    #     ["poetry", "install"],
    #     working_directory = str(managed_root),
    # )

    _symlink_packages(repository_ctx)
    _symlink_project_files(repository_ctx)
    _render_templates(repository_ctx)

pdm_environment = repository_rule(
    attrs = {
        "project": attr.label(
            mandatory = True,
            allow_single_file = True,
            doc = "The label of the pyproject.toml file.",
        ),
        "lock": attr.label(
            mandatory = True,
            allow_single_file = True,
            doc = "The label of the pdm.lock file.",
        ),
        "config": attr.label(
            mandatory = True,
            allow_single_file = True,
            doc = "The label of the .pdm.toml config file.",
        ),
    },
    implementation = _pdm_environment_impl,
)
