# WebAPI

This is separate from the [Luau API](../api/index.md). The Luau API runs checks inside an executor. This API only uploads and reads the finished report.

Base URL: `https://myriad.tools`

## Status codes

These are the check statuses Myriad already uses.

!!! warning
    They are not the HTTP status of the WebAPI.

### Standards

| Status | Meaning |
| ------ | ------- |
| 200 | Passed |
| 0 | The call errored |
| 400 | Global not found |
| 401 | Dependency not found |
| 500 | Failed the functionality test |
| 501 | Missing alias |

Anything other than 200 is a failed standards check.

### Vulnerabilities

| Status | Meaning |
| ------ | ------- |
| 200 | Secured |
| 400 | Vulnerable |
| 404 | Ambiguous |

## Reading a result

`GET /api/results/{type}/{id}` returns JSON. Browsers on other sites can read it (`Access-Control-Allow-Origin: *`).

`GET /api/latest/{type}/{executor}` returns the current result for that executor. Add `?version=1.2.3` to lock the version.

`GET /api/executors` lists executors that have a counted run.

`GET /view/{type}/{id}` is the HTML page.

`GET /embed/{type}/{id}` is the iframe widget. Add `?theme=detailed` to list the checks.
