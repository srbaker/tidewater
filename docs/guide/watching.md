# Watching

A view updates when something it **watches** is committed. You rarely say what that is: by default, a view watches everything it can reach from its instance variables.

## What's reached

Starting from a view's instance variables, Tidewater follows every reference it finds, and watches each object along the way. It stops at:

- **aggregate roots**: instances of `TwRoot`, which are watched, but not looked inside;
- **other views**, which watch for themselves;
- objects that can't change: numbers, characters, symbols, `nil`, `true`, `false`, classes, and invariant objects.

Only committed objects can be watched, and a view watches at most 1,000 of them. Its watches are taken again after every change, so a new item added to a collection is watched from then on.

## Aggregate roots

Following every reference works for a counter, and stops working for a list of ten thousand orders. An **aggregate root** is an object that owns others, and promises to change itself whenever they change. Subclass `TwRoot`, and end every change with `self touch`:

```methods
TodoList >> add:
TodoList >> clear
```

`touch` bumps the root's `version`, so the root itself is part of every commit that changes what it owns. A view then needs to watch only the root, however much is inside it.

Change a root's insides only through its own methods, so nothing changes them without a `touch`.

## Saying exactly

A view can say exactly what it watches by implementing `watches`, answering a collection of objects:

```smalltalk
OrderView >> watches
	^ {order. order customer}
```

## Code

A view's code is watched too: its class's methods, its superclasses' up to `TwView`, and its children's. Change a method and commit, and every page showing that view re-renders with the new method.

## When a page doesn't update

The one bug watching can cause is a page that doesn't update: something it shows changed, but nothing it watches did. Usually that's a change inside an aggregate root that forgot to `touch`.

Two things catch it. While developing, `app warnTo: Transcript` checks every open view whenever a page is opened, and reports a view whose render changed when nothing it watches did:

```
TodoView changed without a watched object changing; watch more, or put it behind a TwRoot
```

And in tests, [`assertView:noticesChangesBy:`](./testing) fails on the same mistake.
