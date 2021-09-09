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
