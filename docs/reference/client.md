# The client

What `tidewater.js` adds to a page. See [In the browser](../guide/browser).

## JavaScript

| | |
| --- | --- |
| `tidewater.hook(name, { mounted, updated })` | Defines a hook. Each callback is given the element, `mounted` when it appears and `updated` after it's patched. |
| `tidewater.travel(steps)` | Shows the view as it was, `steps` renders ago when negative. |
| `tidewater.present()` | Ends time travel, and shows the latest render. |

## Attributes

On the view's element, `[tw-view]`:

| | |
| --- | --- |
| `tw-view` | The view's id. |
| `tw-connected` | Set while its event stream is open. |
| `tw-reconnecting` | Set while it's reconnecting. |
| `tw-traveling` | Set while showing an earlier render. |

On elements inside it, as written by [`TwHtml`](./html): `tw-click`, `tw-submit`, `tw-input`, `tw-debounce` and `tw-hook`.

## Events

The event stream at `/events/<view>` sends each render as a message. A `gone` event means the server no longer knows the view, and the page reloads.
