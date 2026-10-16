# Testing

Views are plain objects, so test them with plain SUnit. Make one on a model, run its actions, and look at what it renders:

```smalltalk
TodoViewTest >> testShowsItsItems
	| list |
	list := TodoList new.
	list add: 'milk'.
	self assert: ((TodoView on: list) render includesString: '<li>milk</li>')

TodoViewTest >> testRefusesABlankItem
	| form |
	form := TodoForm on: TodoList new.
	form add: (Dictionary new at: 'item' put: ''; yourself).
	self assert: (form render includesString: 'can''t be blank')
```

Actions are just methods, so a test calls them directly, without a server or a transaction.

## Does it notice?

`TwTestCase` adds one assertion, for the one bug a live page can have — a change that shows up in the render without anything the view watches changing:

```smalltalk
TodoViewTest >> testNoticesNewItems
	| list |
	list := TodoList new.
	self assertView: (TodoView on: list) noticesChangesBy: [list add: 'milk']
```

It renders the view, runs the block, and renders it again. If the render changed, something the view watches must have changed too, or the assertion fails. Subclass `TwTestCase` to use it.

## In the browser

Tidewater's own acceptance tests drive real browsers with [Playwright](https://playwright.dev) against real gems; see `acceptance/` in the repository. Its unit tests for the client and the front end run the same way, without a stone.
