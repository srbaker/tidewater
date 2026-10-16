# TwApp

Serves views over HTTP. See [Serving an app](../running/serving).

## Making one

| Message | |
| --- | --- |
| `TwApp on: aBlock` | An app whose views are made by `aBlock`, one per visit. |
| `TwApp on: aBlock in: aSession` | The same, with a session of your own, for tests. |

## Setting it up

| Message | |
| --- | --- |
| `script: aFile` | Serves a JavaScript file, and includes it in every page. `aFile` is a file reference. |
| `name: aString` | Names a worker, for the [front end](../running/scaling). Its views' ids start with it. |
| `warnTo: aStream` | Reports views that change without anything they watch changing. |
| `clock: aBlock` | Answers the time in milliseconds, for sweeping idle views. For tests. |

## Serving

| Message | |
| --- | --- |
| `serveOn: aPort` | Serves on the port, and doesn't return. |
| `serve: aListener on: aPort` | The same, with a listener of your own, for tests. |
| `push` | Sends every view's new render to its pages. Called when something watched is committed. |
| `sweep` | Forgets views that have had no open stream for a minute. |
| `viewAt: anId` | Answers the view, or child view, with that id. |
