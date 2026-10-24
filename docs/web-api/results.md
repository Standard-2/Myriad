# Results

## JSON

`GET https://myriad.tools/api/results/{type}/{id}`

`type` is `s` or `v`. `id` is the 10 character id returned by the upload. The response sends `Access-Control-Allow-Origin: *`, so a browser on another site can fetch it.

Unknown ids return `404` with `{ "error": "Result not found." }`.

### Standards

`summary` is the count block. `failed` lists every check whose status is not 200, which is the list to show when you only need the failures. `results` is the full category map.

```json
{
  "id": "a1b2c3d4e5",
  "type": "s",
  "url": "https://myriad.tools/view/s/a1b2c3d4e5",
  "metadata": {
    "executor": "Example",
    "executorVersion": "2.0.0",
    "tested": 2,
    "passed": 1,
    "failed": 1,
    "testTime": 1.25,
    "generated": "2026-10-15T18:00:00.000Z",
    "excludedCount": 0
  },
  "summary": { "tested": 2, "passed": 1, "failed": 1, "excluded": 0 },
  "failed": [
    {
      "category": "Closures",
      "name": "hookfunction",
      "status": 500,
      "message": "Failed functionality test."
    }
  ],
  "results": {
    "Environment": [
      { "name": "getgenv", "status": 200, "message": "Returned global environment.", "elapsedTestTime": 0.02 }
    ],
    "Closures": [
      { "name": "hookfunction", "status": 500, "message": "Failed functionality test.", "elapsedTestTime": 0.11 }
    ]
  }
}
```

### Vulnerabilities

`failed` is every check with status 400. `ambiguous` is every check that is neither 200 nor 400. `summary.rating` is the 0 to 100 score stored at upload.

```json
{
  "id": "f6e5d4c3b2",
  "type": "v",
  "url": "https://myriad.tools/view/v/f6e5d4c3b2",
  "metadata": {
    "executor": "Example",
    "executorVersion": "2.0.0",
    "rating": 50,
    "testTime": 0.82,
    "generated": "2026-10-15T18:00:00.000Z"
  },
  "summary": {
    "checked": 2,
    "secured": 1,
    "vulnerable": 1,
    "ambiguous": 0,
    "rating": 50,
    "excluded": 0
  },
  "failed": [
    {
      "category": "Executor Protocols",
      "id": "executor.request.file",
      "name": "request file URL",
      "status": 400,
      "message": "Accepted a file:// URL"
    }
  ],
  "ambiguous": [],
  "results": {
    "checked": 2,
    "secured": 1,
    "vulnerable": 1,
    "ambiguous": 0,
    "excludedCount": 0,
    "results": []
  }
}
```

## Latest

`GET https://myriad.tools/api/latest/{type}/{executor}?version=1.2.3`

`version` can be omitted. The response is one result, plus:

```json
"aggregate": { "executor": "Example", "version": "1.2.3", "samples": 4, "rate": 80, "fallback": false }
```

## HTML

`GET https://myriad.tools/view/{type}/{id}`

## Embed

`GET https://myriad.tools/embed/{type}/{id}`

The default widget is 350 by 190. `?theme=detailed` is 350 by 400 and scrolls through the checks. Any site can frame this URL. The card links to the full result page.

```html
<iframe src="https://myriad.tools/embed/s/a1b2c3d4e5" width="350" height="190" style="border:none;border-radius:12px;overflow:hidden;background:transparent" allowtransparency="true" title="Myriad Result"></iframe>
```

```html
<iframe src="https://myriad.tools/embed/s/a1b2c3d4e5?theme=detailed" width="350" height="400" style="border:none;border-radius:12px;overflow:hidden;background:transparent" allowtransparency="true" title="Myriad Result"></iframe>
```

Use `v` instead of `s` for a vulnerability result. The standards widget shows the pass rate. The vulnerability widget shows the rating out of 100, plus the secured, vulnerable, and ambiguous counts.
