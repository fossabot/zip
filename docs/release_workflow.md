# How is Zip released?

Zip uses [Bakeware](https://github.com/spawnfest/bakeware) to create a
self-contained pre-compiled executable binary.

Zip is configured to generate said binary `zip` at it's root directory upon `ZIP_RUN_CLI=true mix release`.

## How the release is setup

The `defp release` function in `mix.exs` defines the main parameters for the release generation.
`Zip.Deploy.copy_files/1` is a custom step that copies the self-contained binary to the current
working directory.

### Caveats

The main application module is set as `Zip.Cli`, which is a `Bakeware.Script`.
Due to a bug in `Bakeware.Script`, the system env var `BAKEWARE_ARGC` is required to be defined.
We circumvent this by setting this as "0" by default in `config/config.exs`, in case it isn't already set.

Also, we don't want the usage string to be printed and want an `IEx` shell when we run `iex -S mix` during development.
As such, the `print_usage` config for `Zip.Cli` is defined as `false` outside of Mix Releases.