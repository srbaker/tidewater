# What is Tidewater?

Tidewater is a web framework for [GemStone/S](https://gemtalksystems.com/products/gs64/) in which pages stay live.

A page is drawn by a **view**, a Smalltalk object that writes HTML. A view shows persistent objects, and Tidewater watches them. Whenever anything commits a change to one of them — an action from a browser, a script, a colleague in a workspace — every view showing it re-renders, and its page is patched in place.

So there's no client-side application to write, and no API between it and the server. The database *is* the application's state, and the pages follow it.

## What it looks like

Here is the counter from the examples. A plain object holds the count:

```methods
Counter >> increment
```

A view renders it, and offers one action:

```methods
CounterView >> renderOn:
CounterView >> actions
CounterView >> increment
```

`html button: {#onClick -> #increment} with: '+'` writes a button that runs `increment` when it's clicked. The action commits, the counter changes, and every page showing that counter is sent its new HTML.

## What it's built on

- **GemStone/S** keeps the objects, runs the views, and tells Tidewater what changed, through its notify set.
- **[WebGS](https://github.com/jgfoster/WebGS)** serves HTTP from a gem.
- **[morphdom](https://github.com/patrick-steele-idem/morphdom)** patches each page with the HTML it's sent, with a small script of Tidewater's own around it.

## Where next

- [Getting started](./getting-started) loads Tidewater and runs the examples.
- [Views](./views) is the place to start the guide.
- [Inside Tidewater](../how-it-works) explains how a commit reaches every page.
