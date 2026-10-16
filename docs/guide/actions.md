# Actions

An action is a method on a view that a page may run. A view lists them in `actions`:

```methods
CounterView >> actions
CounterView >> increment
```

Only listed selectors can be run. A page asking for anything else gets a 404, so a view's other methods are safe from the browser.

An element runs an action with `#onClick`, `#onSubmit` or `#onInput`:

```smalltalk
html button: {#onClick -> #increment} with: '+'
```

## Fields

An action named with a colon receives the posted form fields, as a dictionary of strings:

```methods
TodoForm >> actions
TodoForm >> add:
TodoForm >> renderOn:
```

The form names the action without its colon, `#onSubmit -> #add`; Tidewater finds `add:` and passes it the fields. `#onInput` sends one field, named for the input, which is how the todo list's filter works:

```methods
TodoView >> filter:
```

## Transactions

Each action runs in its own transaction. Tidewater aborts, so the action sees the latest committed state, runs it, and commits.

If the commit conflicts with someone else's, Tidewater aborts and runs the action again, up to ten times. So an action should be safe to repeat: work from the objects it's given, not from anything it remembered before. After ten conflicts the page gets a 409 and nothing is committed.

## What comes back

When the action is done, the view renders, and that HTML goes straight back to the page that ran it. Every other page showing the same objects hears of the commit through the [notify set](../how-it-works), and updates a moment later.

An action that only changes the view itself, such as `filter:`, commits nothing persistent, so only its own page changes. That's what [state](./state) is about.
