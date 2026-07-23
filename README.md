<!-- markdownlint-disable MD033 MD041 -->

<div align="center">

# Myriad General Validity Test

[![Standard-2][badges/org]][org]

[![Stars][badges/stars]][stars]
[![Latest Release][badges/lastrel]][lastrel]
[![Last Modified][badges/lastcom]][lastcom]
[![License][badges/license]][license]

[![Website][badges/site]][site]
[![Discord][badges/disc]][disc]

<br>

**Myriad is an open-source standardization, functionality, and mitigation testing suite for executors.**

After the discontinuation of [UNC][unc], multiple forks and continuations emerged, alongside separate executor tests focused on areas such as vulnerabilities and identity checks. Myriad aims to un[...]

</div>

## Table of Contents

- [Quick Start](#quick-start)
- [API](#api)
- [Brand Assets](#brand-assets)
- [Contributing](#contributing)
- [Supporting the Project](#supporting-the-project)

## Quick Start

```luau
loadstring(game:HttpGetAsync("https://github.com/Standard-2/Myriad/releases/latest/download/myriad.luau"))()
```

> **[Run within Myriad's testing game][roblox-game]**
>
> *Myriad performs testing inside a Roblox experience because certain executor behaviors can only be accurately evaluated within the game environment, ensuring consistent and reliable results.*

## API

The API allows developers to run individual tests programmatically without launching the Myriad UI. This is useful for debugging specific functionality, validating executor implementations, or int[...]

See our [API Documentation][api-docs]

### Example

```luau
local API = loadstring(game:HttpGetAsync("https://github.com/Standard-2/Myriad/releases/latest/download/api.luau"))()

local result = API.Standards.Checks.Closures.hookfunction()
if result.status ~= 200 then
    warn(`Your executor does not support hookfunction properly: {result.message}`)
end
```

> **Note**
>
> Certain checks in the **Myriad standards test** rely on references that are only accessible within the [Myriad testing game][roblox-game].

## Brand Assets

Myriad's official brand assets are available in the [`assets`][brand-assets] directory. These resources are provided for use in official communications and project materials.

- **Standard2-Logo_BlackBG_WhiteIcon.png** – Standard-2 logo with black background and white icon
- **Standard2-Logo_NoBG_WhiteIcon.png** – Standard-2 logo with transparent background and white icon

## Contributing

Contributions are welcome!

See the [**Building from Source**][build-docs] guide for complete setup and build instructions.

## Supporting the Project

If you'd like to support the project, consider donating via any of these:

- **LTC**: `Lcd6pCPiVw9GH2MAaGkR8TX39EtL2LzFoa`
- **SOL**: `EfwivXazedEw2kL2et92NKDkT3qrQ6pdxA8Bs7RKYRuN`
- **ETH**: `0x85C09A302CBB42a321E737E6E4dDAC0Eebc4ac3E`
- **BTC**: `bc1qlhym0f0lejwlhd47gext8g7fgej366j7z85vvx`

<!-- References -->

<!-- Project -->
[org]: https://github.com/Standard-2
[unc]: https://github.com/unified-naming-convention/NamingStandard

<!-- Site & Docs -->
[site]: https://myriad.tools
[build-docs]: https://docs.myriad.tools/getting-started/building-from-source/
[api-docs]: https://docs.myriad.tools/api/

<!-- Assets -->
[brand-assets]: https://github.com/Standard-2/Myriad/tree/main/assets

<!-- External -->
[disc]: https://discord.gg/nn4NxHU3Pu
[roblox-game]: https://www.roblox.com/games/79035306837882

<!-- GitHub -->
[stars]: https://github.com/Standard-2/Myriad/stargazers
[lastrel]: https://github.com/Standard-2/Myriad/releases/latest
[lastcom]: https://github.com/Standard-2/Myriad/commits
[license]: https://github.com/Standard-2/Myriad/blob/main/LICENSE

<!-- Badges -->
[badges/org]: https://img.shields.io/badge/Standard--2-Myriad-black?logo=data%3Aimage%2Fpng%3Bbase64%2CiVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAA[...]
[badges/stars]: https://img.shields.io/github/stars/Standard-2/Myriad?logo=github
[badges/lastrel]: https://img.shields.io/github/v/release/Standard-2/Myriad?logo=github&label=release
[badges/lastcom]: https://img.shields.io/github/last-commit/Standard-2/Myriad?logo=github&label=last%20commit
[badges/license]: https://img.shields.io/github/license/Standard-2/Myriad?logo=github
[badges/site]: https://img.shields.io/website?url=https%3A%2F%2Fmyriad.tools&up_message=https://myriad.tools&up_color=success&logo=googlechrome&logoColor=white&label=website
[badges/disc]: https://img.shields.io/discord/1371325686278651985?logo=discord&logoColor=white&label=discord
