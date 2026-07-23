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

After the discontinuation of [UNC][unc], multiple forks and continuations emerged, alongside separate executor tests focused on areas such as vulnerabilities and identity checks. Myriad aims to unify these efforts into a single, comprehensive test suite.

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

The API allows developers to run individual tests programmatically without launching the Myriad UI. This is useful for debugging specific functionality, validating executor implementations, or integrating Myriad into other tools.

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
[badges/org]: [badges/org]: https://img.shields.io/badge/Standard--2-Myriad-black?logo=data%3Aimage%2Fpng%3Bbase64%2CiVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAOdEVYdFNvZnR3YXJlAEZpZ21hnrGWYwAACKVJREFUeAHtnV1SE0sUgHuCWJQ%2B3OzA8OAfZdUlK7hxBeauQFiBugJgBeIKwBUQV0BcAfgiEqtk7grMg8UDP3LPiT2pyWR%2Bunv6d%2BZ8VZjETJjQ8%2BX06dM9k4i1hLOzs0Gn0zngD3sFm8XwM42iaHp3d4e3%2BDi%2Bvb39Aj%2FTFy9enLKGEbEWcX5%2BvgM3u0wRFANuUILTm5ubz%2FD49Pnz5zELmOAEODk56a6trW3CJ7S7sbExYpLUlSCHUxQBIsRHkGHMAiMYATCEr6ysvIa7Qzz4%2FL%2B3nj59%2BpFJYkCCGTxCjCA6fFKR0wVeCzCZTPCTPoSGfZM66Fm8kiBFDO97DJFhz%2BduwlsB4OAfwEHfEtzcVwlmpEQYM8%2FwVgAI%2BT3I2o9ZccaexWsJODHuS%2BV9msLrLqChEiAx80QE75PABkuAjH7%2F%2Fv3OZY4QxCig4RIge5eXl%2Fv9fn%2FKLGNdABzOwU0sa30LJIghGmzbThQ7zBJYwIHMfh8PIv7gAZV5PQoDDfSS%2Fek%2FRTiEg%2FmaSQLS7DE3AswEhzZ6zyxiJQIUfHpnB5QiQS5KbaOC8QgARm9BBe%2BELR%2BwHkWCQrBtTr5%2B%2FfqWGcZoBMCQD8WcNxWbUSQoZw%2Fe9y4zhDEBoOGGcHMkuDlJUM4IRgnbJkYJRiOAZMORBOUYyQuMJ4EkgVa0S2BlFEASaEWrBNYKQSSBVrRJYLUSSBJoRYsE1iqBiOTYmuoE5WD7HGGFldWglgBQqBhKvoQk0MvmgwcPDlgNlAWABtuFCt8R3jJJSAKtDOvMHyjlAN%2B%2BfXsbRVF6p0rVKsoJtKL0vqUFwAbF2n7OIk2SwK0EU2ibvmzbSHcB2JAFK3R3qDtw2h10sW1kk0IpAXByh5V%2FikgCx7OIDx8%2B3JF5gXAXwM%2BtOxbcnLoDh90Bb5exyLYyESBm4p8eigQOIwGeBCvaFQgLoNBwJIHD5WVQH6hahzFDaRQgGUKpO3DUHUCbrFe1ifQogCJBOJEAhuuVVUKlSiBJEIYEMFwf8GX4hSiXgkmCMCSAKFA6LKw1GUQS%2BC9BVRSoPR1MEvgvQVkU0LIegCTwW4KyKJArAPxBhxYajiSwKEFRFFiqA%2FCx8QWzN7amOoGlOsH19XU%2Fe6m7pQiQMsXWp4cigaVIsLq6%2Bir7f0sCYH%2BRekgSNEuCpXMNFwTgp3P1MtuQBM2RoJtNBhcEiKLoVcELSYKGSADHeOE9ZbuAslW%2BJEEDJAABhump4rkAGBpKLsaYQBKEL8HsUrvJg7kA0Biia8lIgsAlSHf1ndTO8JJl24K%2FgyQIWALsBpL7CzkA%2FFGHJIE4AUvQ%2B%2FHjxyO8s1QHIAnaIQFUBQd4mzsXQBI0XwJI%2BGeJYOFsIEnQbAkgDxjgbel0MEnQaAl6%2BE8ksiU0xFbqC5eqoFnEQGYRYXKoJ7QghCJBMyPB1dXVpsyJISSBBIFI0BMWACEJGieBnAAISdAoCbodvgZACpKgMRLMIsB7lYYjCcKXAGoB8y5ghyRopwQoQI%2FfJwnaJ8FSEkgStEyCvFEASdAiCYqGgSRBSyQoqwOQBC2QoKoQRBI0XIKOwE5JguZKEIuWgkmCZkow7UA1KBZ8HUnQMAlub2%2F3OrCzWOJ1JEGDJNjY2BjB%2B%2BvIfhcdSdAgCUSSwDxIgoZI0Lm7u%2FuPqUESNEACzAFOmTokQeASRPjPZDL5KXBmcBlKK3RptbH71cZJHSBm9aBIEGgkSAQYs%2FqQBAFKMBMACgJfmB5IgsAk0BkBEkiCgCSIkjvw5AUTTy5EoMQwgMRwPhkEcwIjpheKBJ5GgvRX%2Fs4FgDzgE9MPSeChBKurqz%2BT%2B3MB1tbWTiEKyM4LiEAS%2BCXB9PHjx5%2BTB3MB1tfX8atHdXcDCSSBJxJAwW%2FhGHcyT5ZWjWpCEvghwYIAUfZZDWXhKmh04G50EMP7XU9vl3e18H1mFooEjiIBHNtxdrslASARNDEayEISOJAABNjLbrMkwJMnT3A0MGbmIQksSgAH%2FzCvG4nyXnQm903hdaGcwEJOUERU9AQkg8eZbw8xCUngSILC8wJwyTCzB3UHFrqDPKKyJy1HAYQigeVIUHpmkOUogFAksBwJoqoNHEQBhCKBpUhQeW4gRAHRT5ZOKBJYigSVAnCrdpl9SAILEgidHXz%2F%2Fv0PrP7KYRVIAsMSCAnAp4pddAUISSApwb179x4JbstkLhY9hhKx6YmiIkgCQQlwMi%2B94KOKylFAmouLi%2B7V1dUJ07t4VAYaHZSPDpame6uQulg07wpeGlo6JgJFgoJIgMeE718KlauFxzA0fMfcQRLkSAD73TVSB8gDG9NhPoCQBIsS7D579uwDU0AqB8jy%2Ffv3I%2FhjpS83r5HW5wRwDF5B0qe8iKeWAJgUXl9fHyffQeeI1ktQB6UuIAGTQsgH%2FmVuikQJre8O6lArAiQomG4CigQKaBEAIQkq9%2BGlBNoEQEiCyn14J4FWARCSoHIfXkmgXQAERwc3NzcHNEQs3IeUBJho41U9mQGMCJBwXvO7bTUQvAQ4uQNFHmOV11rDwCqwWgV%2FwDuaO8jdR%2BkQkbfZlsmDP9sPs4AHeUFokUDryR9lGI0ACfiH4DQlrSfI3Uf2%2FL39y8vLvo2Dj1iJAGn4aWf4qeox%2B3gdCXAlj8xiDh1YFwDhC0veMDcJorcSuMCJAAm8%2F3sPd20PF0kCjlMBEnjD4pCxx%2BxBEjBPBEhwIELrJbAyChAFs24cLUDjDvIuZ2IAK6MDGP3sME%2FxKgJkwRwBGw9%2BBsxsVNAeCbCQw6%2B3NILfreti3NrxWoA0uPQJauJDaPChoauY1ZaAr8wdraysHNoezqkSjABpQIZ%2FQIYtaHBciqZzOZrqWn0U8%2BevX7%2B%2B9Pt9V2VvJYIUIA0voPwNQgzg4SYciE0XX38TKsELkMdkMtmE6PAXLlaFkIx5RA%2BlgNsuv%2B3lvQ6ei%2FntNp4Kx1rA%2F%2B5l4VzWtZrGAAAAAElFTkSuQmCC
[badges/stars]: https://img.shields.io/github/stars/Standard-2/Myriad?logo=github
[badges/lastrel]: https://img.shields.io/github/v/release/Standard-2/Myriad?logo=github&label=release
[badges/lastcom]: https://img.shields.io/github/last-commit/Standard-2/Myriad?logo=github&label=last%20commit
[badges/license]: https://img.shields.io/github/license/Standard-2/Myriad?logo=github
[badges/site]: https://img.shields.io/website?url=https%3A%2F%2Fmyriad.tools&up_message=https://myriad.tools&up_color=success&logo=googlechrome&logoColor=white&label=website
[badges/disc]: https://img.shields.io/discord/1371325686278651985?logo=discord&logoColor=white&label=discord
