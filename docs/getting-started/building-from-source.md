# Building From Source

Before doing anything, open a terminal and set its [cd] to the Myriad source repository.

You can [:lucide-download: Download source][myriad-source] from the official repository or clone the [Myriad Repository][myriad-repository].

!!! tip
    You can use `#!bash git clone "https://github.com/Standard-2/Myriad.git"` if you have `git` installed

## Installing [aftman] & dependencies

Aftman is a package manager that automatically installs the required dependencies needed to build Myriad.

1. First, install [aftman] if you don't already have it.

    > Ensure it's in your [Environment Variables][environment-variables], this allows [aftman] to be accessed from a terminal.

2. Run `aftman install` in the Myriad directory to install all required dependencies.

## Building a release

Myriad uses [ProCMP] for build composition.

- To build a release with [ProCMP], use `pcmp pipeline/.pcmp.json`. This will run the compositor using our PCMP configuration. After this, you can select a build configuration, such as debug.
- Artifacts will appear in `generated/`.

## Common mistakes

??? question "How do I get the Myriad source downloaded?"
    Either [:lucide-download: Download source][myriad-source] from the [Myriad Repository][myriad-repository] releases page, or if you have `git` just run:

    ```bash
    git clone "https://github.com/Standard-2/Myriad.git"
    ```

??? question "`#!bash aftman` isn't being recognized in my terminal"
    It's probably not in your [Environment Variables][environment-variables]. Add aftman to your PATH and restart your terminal, it won't pick up the change otherwise.

??? question "`#!bash aftman install` isn't doing anything / errors out"
    Make sure your terminal is [cd]'d into the Myriad directory, not just somewhere on your system. aftman looks for `aftman.toml` in the current folder.

??? question "`#!bash pcmp` isn't recognized either"
    Same deal as aftman, after `aftman install` finishes, the tools it installed need to be in your PATH. Restart your terminal and try again.

??? question "`#!bash darklua` issues / Build error: `#!bash generated/release/dist.luau — system cannot find path`"
    darklua probably didn't install properly even if `aftman install` ran fine. Check by running:

    ```bash
    darklua --version
    ```

    If that errors out, aftman installed it but it's not in your PATH yet. Try restarting your terminal first and running it again.

    If it still doesn't work, install darklua manually from the [v0.18.0 release page](https://github.com/seaofvoices/darklua/releases/tag/v0.18.0) and add it to your [environment variables] yourself.

??? question "Build finished but I can't find the output"
    Check `generated/` in the Myriad directory. That's where artifacts are placed after a successful pipeline run.

<!-- References -->

<!-- Project -->
[myriad-repository]: https://github.com/Standard-2/Myriad
[myriad-source]: https://github.com/Standard-2/Myriad/archive/refs/heads/main.zip

<!-- Tools -->
[aftman]: <https://github.com/LPGhatguy/aftman>
[ProCMP]: <https://github.com/Proton-Utilities/ProCMP>

<!-- Documentation -->
[environment-variables]: <https://www.howtogeek.com/787217/how-to-edit-environment-variables-on-windows-10-or-11/>
[cd]: <https://en.wikipedia.org/wiki/Cd_(command)>
