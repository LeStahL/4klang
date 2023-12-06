from distutils.command.build_ext import build_ext
from distutils.errors import (
    CCompilerError,
    DistutilsExecError,
    DistutilsPlatformError,
)
from distutils.core import Extension
from os.path import (
    dirname,
    join,
    abspath,
    exists,
)
from os import mkdir, environ
from subprocess import run
from platform import system
from sys import exit

class BuildFailed(Exception):
    pass

class ExtBuilder(build_ext):
    def run(self):
        try:
            build_ext.run(self)
        except (DistutilsPlatformError, FileNotFoundError):
            raise BuildFailed('File not found. Could not compile C extension.')

    def build_extension(self, ext):
        try:
            build_ext.build_extension(self, ext)
        except (CCompilerError, DistutilsExecError, DistutilsPlatformError, ValueError):
            raise BuildFailed('Could not compile C extension.')

def build(setup_kwargs):
    # Make sure the build directory exists and setup the
    # relative paths correctly.
    cwd = abspath(".")
    print("Running from:", cwd)

    current_source_dir = abspath(join(dirname(__file__), '..'))
    project_source_dir = abspath(join(current_source_dir, "..", ".."))
    current_binary_dir = join(current_source_dir, 'build')
    if not exists(current_binary_dir):
        mkdir(current_binary_dir)
    host_is_windows = system() == "Windows"

    # Get GOBIN path.
    result = run(
        args=[
            "go", "env", "GOPATH",
        ],
        cwd=project_source_dir,
        shell=host_is_windows,
        capture_output=True,
    )
    if result.returncode != 0:
        print("go env process exited with:", result.returncode)
        print(result.stdout, result.stderr)
        exit(1)

    gopath = result.stdout.decode('utf-8').strip()
    gobin = join(gopath, 'bin')
    assert exists(gobin)
    print("GOPATH:", gobin)

    # Get Python venv path.
    result = run(
        args=[
            "poetry", "env", "info", "--path",
        ],
        cwd=current_source_dir,
        shell=host_is_windows,
        capture_output=True,
    )
    if result.returncode != 0:
        print("poetry env info process exited with:", result.returncode)
        print(result.stdout, result.stderr)
        exit(1)

    pyenvpath = result.stdout.decode('utf-8').strip()
    python = join(pyenvpath, 'bin', 'python')
    assert exists(python)
    print("Python:", python)

    environment = environ.copy()
    environment['PATH'] = ':'.join(environment['PATH'].split(':') + [gobin])

    # Build bindings module using gopy.
    print("Using gopy to generate Python bindings.")
    result = run(
        args=[
            "gopy",
            "build",
            "--output={}".format(current_binary_dir),
            "-vm={}".format(python),
            "-name=sointu",
            project_source_dir,
        ],
        cwd=current_source_dir,
        shell=host_is_windows,
        env=environment,
        capture_output=True,
    )
    if result.returncode != 0:
        print("gopy build process exited with:", result.returncode)
        print(result.stdout, result.stderr)
        exit(1)

    # Build go part of bindings using cgo.
    print("Using go to generate cgo library.")
    result = run(
        args=[
            "go", "build",
            "-buildmode=c-shared",
            "-o", join(current_binary_dir, "libsointu_go.so"),
            join(current_binary_dir, "sointu.go"),
        ],
        cwd=current_binary_dir,
        shell=host_is_windows,
        env=environment,
        capture_output=True,
    )
    if result.returncode != 0:
        print("go build process exited with:", result.returncode)
        print(result.stdout, result.stderr)
        exit(1)

    # Export the plugin.
    print("Exporting the gopy-generated bindings.")
    setup_kwargs.update({
        "ext_modules": [
            Extension(
                "sointu",
                include_dirs=[
                    current_binary_dir,
                    current_source_dir,
                ],
                sources=[
                    join(current_binary_dir, "sointu.c"),
                ],
                library_dirs=[
                    current_binary_dir,
                ],
                libraries=[
                    "sointu_go",
                ],
                depends=[
                    join(current_binary_dir, "libsointu_go.so"),
                ],
                runtime_library_dirs=[
                    current_binary_dir,
                ],
                extra_link_args=[
                    # TODO
                ] if host_is_windows else [
                    "-z", "noexecstack",
                    "--no-pie",
                ],
            ),
        ],
        "cmdclass": {
            "build_ext": ExtBuilder,
        },
    })
