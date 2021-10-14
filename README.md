# [Bazel](https://bazel.build/) rules to be used with [pdm](https://pdm.fming.dev/)

## Usage

Add the following content to your `WORKSPACE`:

```bzl
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

git_repository(
    name = "rules_python_pdm",
    remote = "https://github.com/xulongwu4/rules_python_pdm.git",
    tag = "v1.1",
)

load("@rules_python_pdm//:environment.bzl", "pdm_environment")

pdm_environment(
    name = "pdm_environment",
)

register_toolchains("@pdm_environment//:pdm_toolchain")
```
