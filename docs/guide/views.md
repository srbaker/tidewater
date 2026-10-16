# Views

A view subclasses `TwView` and implements `renderOn:`, writing its HTML on the canvas it's given:

```methods
TodoView >> renderOn:
```

The canvas is a `TwHtml`. Each element is a message named for its tag.

## Content

An element's content is a string or a block:

```smalltalk
html h1: 'Groceries'.
html ul: [
	html li: 'milk'.
	html li: 'bread']
```

```html
<h1>Groceries</h1><ul><li>milk</li><li>bread</li></ul>
```

A block writes the element's children. Strings are always escaped, so `html p: '<b>'` shows the angle brackets rather than making text bold.

## Attributes

Attributes come first, as an array of associations, and the content follows `with:`:

```smalltalk
html a: {#href -> '/help'. #class -> 'quiet'} with: 'Help'
```

```html
<a href="/help" class="quiet">Help</a>
```

Values are escaped too, and printed if they aren't strings, so `#debounce -> 200` is fine.

Void elements, such as `input`, take only attributes:

```smalltalk
html input: {#name -> 'item'. #placeholder -> 'Something to buy'}
```

## Tidewater's attributes

Alongside plain HTML attributes, a few keys connect an element to its view:

| Key | Does |
| --- | --- |
| `#onClick -> #action` | Runs the action when the element is clicked. |
| `#onSubmit -> #action` | Runs the action with the form's fields when the form is submitted. |
| `#onInput -> #action` | Runs the action with the input's value as it changes. |
| `#debounce -> 200` | With `#onInput`, waits until typing has paused this many milliseconds. |
| `#hook -> #name` | Hands the element to a [hook](./browser#hooks) in the browser. |

Any other key starting `on` and a capital is an error, so a typo such as `#onclick` can't fail quietly.

## Anything else

Not every tag has its own message. `element:with:` and `element:attributes:with:` write any element, and `void:attributes:` any void one:

```smalltalk
html element: 'table' with: [
	html element: 'tr' with: [html element: 'td' with: 'milk']]
```

`text:` writes escaped text with no element around it, and `raw:` writes HTML as it is. `raw:` is the one way to write unescaped HTML, so keep it for HTML you made yourself.

## Rendering

`render` answers a view's HTML as a string, which is handy in a workspace or a test:

```smalltalk
(CounterView on: Counter new) render
	"'<p>0</p><button tw-click=""increment"">+</button>'"
```

A view renders often: on every change to what it watches, and after every action. Keep `renderOn:` free of side effects.

Next: [actions](./actions), which change things.
