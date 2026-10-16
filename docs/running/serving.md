# Serving an app

An app is a `TwApp` made on a factory block, which makes a fresh view for each visit:

```smalltalk
(TwApp on: [TodoView on: (UserGlobals at: #TidewaterTodos)])
	script: (Rowan projectNamed: 'TidewaterExamples') repositoryRoot / 'examples' / 'js' / 'todo.js';
	warnTo: Transcript;
	serveOn: 8080
```

- **`script:`** adds a JavaScript file of the app's own, for its [hooks](../guide/browser#hooks). The page includes it after Tidewater's own scripts.
- **`warnTo:`** reports views that change without anything they watch changing. Use it while developing.
- **`serveOn:`** starts serving, and doesn't return.

## A gem of its own

`serveOn:` blocks, and the gem serving commits actions and aborts as it goes, so run it in a gem of its own, not in the session you develop in. A topaz script is the simplest way:

```sh
topaz -lq <<'TOPAZ'
set user DataCurator pass swordfish gemstone gs64stone
login
run
(TwApp on: [TodoView on: (UserGlobals at: #TidewaterTodos)]) serveOn: 8080
%
TOPAZ
```

`bin/serve` in the repository does this for the examples.

## Persistent roots

A view's model must be committed before the view can watch it. Keep it somewhere reachable, such as a global, and commit it before serving:

```smalltalk
UserGlobals at: #TidewaterTodos put: TodoList new.
System commitTransaction
```

Don't give a global a class's name: `UserGlobals` comes first in the symbol list, so it would hide the class.

## Routes

A `TwApp` answers these:

| Route | Answers |
| --- | --- |
| `GET /` | A new view's page. |
| `POST /<view>/<action>` | Runs an action, and answers the view's new HTML. |
| `GET /events/<view>` | The view's event stream: its render now, then each new one. |
| `GET /views/<view>` | The view's HTML now. |
| `GET /history/<view>` | The view's recent renders, as JSON. |
| `GET /relay` | Every view's renders, for the [front end](./scaling). |
| `GET /<script>` | Tidewater's scripts, and the app's own. |
