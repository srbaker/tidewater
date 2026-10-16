# In the browser

Tidewater's client is one small script, `tidewater.js`, with [morphdom](https://github.com/patrick-steele-idem/morphdom) beside it. A page includes both, and needs nothing else.

## What it does

- **Actions.** It turns clicks, submits and input on elements marked by `#onClick`, `#onSubmit` and `#onInput` into posts to their view, and patches the view with the HTML that comes back.
- **Updates.** It keeps an event stream open to the server, and patches the page with each new render.
- **Typing.** The element being typed in is never patched, so a push never yanks text from under someone's cursor.

Patching changes only what differs, so focus, scroll position and selections elsewhere on the page survive it.

## Connection

The view's element is marked so a page can show whether it's live:

- **`tw-connected`** once the stream is open and has sent its first render;
- **`tw-reconnecting`** while it's trying again.

```css
[tw-view][tw-reconnecting] { opacity: 0.5; }
```

Actions that fail while disconnected are queued, and sent once the stream is back. After a server restart, or once the server has forgotten a view, the page reloads itself onto a fresh one.

## Hooks

Some things only JavaScript can do, like moving focus. A view marks an element with a hook:

```smalltalk
html input: {#name -> 'item'. #hook -> #autofocus}
```

and the app serves a script that defines it:

<<< @/../examples/js/todo.js

```smalltalk
app script: (Rowan projectNamed: 'TidewaterExamples') repositoryRoot / 'examples' / 'js' / 'todo.js'
```

`mounted` runs when a hooked element appears, and `updated` after it's patched. Both are given the element.

## Time travel

A view remembers its last 50 renders. In the browser's console:

```js
tidewater.travel(-2)   // show this view as it was two renders ago
tidewater.present()    // and come back
```

While travelling, the view is marked `tw-traveling`, and pushes wait until it's back.
