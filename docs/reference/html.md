# TwHtml

The canvas a view renders on. See [Views](../guide/views) for a tour.

## Elements

Each of these tags has two messages: `tag: content` and `tag: attributes with: content`.

`a` `button` `div` `form` `h1` `h2` `h3` `label` `li` `ol` `p` `section` `span` `ul`

- **content** is a string, which is escaped, or a block, which writes the element's children. `nil` writes nothing.
- **attributes** is an array of associations, `{#href -> '/help'. #class -> 'quiet'}`. Values are printed with `asString` and escaped.

| Message | Writes |
| --- | --- |
| `input: attributes` | An `<input>`, which has no content. |
| `element: aName with: content` | Any element. |
| `element: aName attributes: attributes with: content` | Any element, with attributes. |
| `void: aName attributes: attributes` | Any void element, such as `img` or `br`. |
| `text: aString` | Escaped text. |
| `raw: aString` | HTML, unescaped. |
| `render: aView` | A child view, marked with its id. |
| `contents` | Answers everything written so far. |

## Tidewater's attributes

| Key | Becomes | Does |
| --- | --- | --- |
| `#onClick` | `tw-click` | Runs an action on click. |
| `#onSubmit` | `tw-submit` | Runs an action with the form's fields on submit. |
| `#onInput` | `tw-input` | Runs an action with the input's value as it changes. |
| `#debounce` | `tw-debounce` | Milliseconds to wait for typing to pause. |
| `#hook` | `tw-hook` | Names a [hook](../guide/browser#hooks). |

Any other key starting `on` and a capital letter signals an error. Every other key is written as it is.
