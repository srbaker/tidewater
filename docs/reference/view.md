# TwView

The superclass of every view.

## To implement

| Message | |
| --- | --- |
| `renderOn: html` | **Required.** Writes the view's HTML on a [`TwHtml`](./html). |
| `actions` | The selectors a page may run. Answers none by default. |
| `children` | The views it contains, in order. Answers none by default. |
| `watches` | The objects whose commits re-render it. By default, everything [reachable](../guide/watching) from its instance variables. |

## To use

| Message | |
| --- | --- |
| `render` | Answers the view's HTML. |
| `id` | Answers the view's id, once it's being served. |
| `viewAt: anId` | Answers this view or the child with that id, or `nil`. |
| `allWatches` | Answers its watches and all its children's. |
| `code` | Answers the method dictionaries of its classes and its children's, which are watched for new code. |
| `history` | Answers its recent renders, oldest first, up to 50. |
