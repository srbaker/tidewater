# Tidewater

A live web framework for GemStone/S. **[Read the documentation.](https://srbaker.github.io/tidewater/)**

Views are Smalltalk objects that render HTML. When anything commits a change to the objects a view shows — a click in a browser, a script, a colleague in another session — every page showing that view updates itself. There is no client-side application code to write, no API to design, and no cache to keep in step with the database: the database *is* the application's state, and the pages follow it.

```smalltalk
CounterView >> renderOn: html
	html p: counter count printString.
	html button: {#onClick -> #increment} with: '+'

CounterView >> actions
	^ #(#increment)

CounterView >> increment
	counter increment
```

Open that page in two browsers and click `+` in one: both show the new count. Commit `counter increment` from a workspace: both update again.

## Trying it

You need:

- **GemStone/S 64 Bit 3.7** with the **Rowan 3** extent (`$GEMSTONE/bin/extent0.rowan3.dbf`). Jasper, GemTalk's extension for VS Code, is the friendliest way to make and run one.
- **[WebGS](https://github.com/jgfoster/WebGS)**, the HTTP server Tidewater runs on, installed into the stone with its `install.sh`.
- A shell with the GemStone environment set (`GEMSTONE` and friends — Jasper's *Open Terminal* does this).

Clone Tidewater next to your other projects, and load it with Rowan, from Jasper or topaz:

```smalltalk
(Rowan projectFromUrl: 'file:/path/to/projects/tidewater/rowan/specs/Tidewater.ston'
	projectsHome: '/path/to/projects') load.
System commitTransaction.
```

Load the examples the same way, from `examples/rowan/specs/TidewaterExamples.ston`. Then run one and open it in a couple of browsers:

```sh
bin/serve todo 8080      # or: bin/serve counter 8080
```

The scripts log in as `DataCurator` to `gs64stone`; set `TIDEWATER_STONE_PASSWORD` and `TIDEWATER_STONE` if yours differ.

## Views

A view subclasses `TwView` and writes its HTML on a canvas:

```smalltalk
TodoView >> renderOn: html
	html input: {#type -> 'search'. #name -> 'filter'. #value -> filter. #onInput -> #filter. #debounce -> 200}.
	html ul: [self visibleItems do: [:each | html li: each]].
	html render: form
```

- `html p: 'text'` writes an element; `html ul: [ ... ]` nests whatever the block writes.
- `html form: {#onSubmit -> #add} with: [ ... ]` puts attributes first. Attribute keys are plain HTML names, plus Tidewater's: `#onClick`, `#onSubmit`, `#onInput`, `#debounce` and `#hook`.
- `html input: {#name -> 'item'}` writes a void element.
- Text and attribute values are always escaped. `html raw:` is the one way to write HTML as it is.

### Actions

A view lists the actions a page may run, and implements them:

```smalltalk
TodoForm >> actions
	^ #(#add:)

TodoForm >> add: fields
	| item |
	item := fields at: 'item' ifAbsent: [''].
	item isEmpty ifTrue: [^ error := 'Item can''t be blank'].
	error := nil.
	list add: item
```

Each action runs in a transaction: Tidewater aborts, runs it, and commits, retrying if the commit conflicts with someone else's. An action named with a colon receives the posted form fields.

### State

Every visit gets its own view, made fresh by the app's factory:

```smalltalk
(TwApp on: [TodoView on: (UserGlobals at: #TidewaterTodos)]) serveOn: 8080
```

So a view's instance variables are that page's own state — what was typed into a filter, a validation error — while the objects it shows are shared, persistent, and live.

### Composing

Views contain views. A view lists its `children` and renders them with `html render: aView`; actions and forms inside a child go to that child.

### Watching

A view watches whatever it can reach from its instance variables, so it updates when any of it is committed. Watching stops at **aggregate roots**: subclass `TwRoot` for an object that owns others, and have its changes end with `self touch`:

```smalltalk
TodoList >> add: aString
	items add: aString.
	self touch
```

A view can also say exactly what it watches by implementing `watches`. A view's own code is watched too, so changing a method re-renders the pages showing it.

### Testing

Test views with plain SUnit. `TwTestCase` adds one assertion, which fails when a change shows up in the render but nothing the view watches changed — the one bug that keeps a page from updating:

```smalltalk
self assertView: (TodoView on: list) noticesChangesBy: [list add: 'milk']
```

While developing, `app warnTo: Transcript` reports the same mistake at run time.

## In the browser

Tidewater's client is one small script and [morphdom](https://github.com/patrick-steele-idem/morphdom). It posts actions, patches the page with what comes back, and keeps an event stream open for changes:

- **`tw-connected`** and **`tw-reconnecting`** mark the view, so a page can show when it is live.
- Actions that fail while disconnected are queued and sent once the stream is back.
- After a server restart, pages reload themselves onto fresh views.
- The element being typed in is never patched underneath the person typing.
- **Hooks** do what Smalltalk can't: a view marks an element with `#hook -> #autofocus`, and the app adds a script of its own with `app script: aFile`:

  ```js
  tidewater.hook('autofocus', { mounted: (element) => element.focus() });
  ```

- **Time travel**: in the console, `tidewater.travel(-2)` shows a view as it was two renders ago, and `tidewater.present()` brings it back.

## Scaling

One gem serves an app comfortably to a thousand or so open pages. Beyond that, run several worker gems behind the front end in `front/`, which holds every browser's connection:

```sh
bin/serve todo 8901 w1 &
bin/serve todo 8902 w2 &
node front/front.js 8080 w1=http://localhost:8901 w2=http://localhost:8902
```

With four workers, a commit reached each of 10,000 open pages within 350ms.

## Running the tests

- **Smalltalk:** run the `Tidewater-Tests` package in Jasper.
- **Everything else:** `npm install`, `npx playwright install chromium`, then `npm test` from a shell with the GemStone environment. It runs the client and front-end unit tests, then acceptance tests in real browsers against real servers.
- **Load:** `node load/fanout.js` and `node load/concurrent.js` measure fan-out and concurrent actions.

## How it works

- A visit asks the app for a view, which renders the page and is kept, by id, while the page is open.
- The gem keeps everything its views watch in GemStone's **notify set**, and polls it every 100ms. When something changed, it aborts to see the new state, re-renders every view, and pushes the HTML down each page's event stream.
- Actions arrive as plain form posts. Their own commits come back round through the same notify set, so a click updates every page showing the same objects.
- Views no browser has looked at for a minute are forgotten.

## Notes from building it

- GemStone's notification interrupt was unreliable in a server gem: it is delivered to whichever process happens to be running, often a request that is about to finish. Polling the notify set is simpler, and hasn't missed a commit in any of our tests since.
- WebGS writes an event stream's headers before handing it over, so a page could see itself connected before it was subscribed. A stream now begins by sending the page its current render.
- WebGS's listener committed on every pass, which made two gems conflict and stop each other. Tidewater's listener aborts instead, and commits only actions.
- A commit that fails and isn't aborted leaves the gem holding the conflict, and WebGS then stops serving. Every action now either commits or aborts.
- Rc classes avoid conflicts on a hot root, but writing into one doesn't reliably signal the notify set, so roots stay plain and conflicting actions retry.

## Status

Tidewater is young. The [issues](https://github.com/srbaker/tidewater/issues) list what it doesn't do yet.

## License

MIT. See [LICENSE](LICENSE).
