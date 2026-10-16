# Composing views

Views contain views. A view lists its `children`, and renders each with `html render:`:

```methods
TodoView >> setList:
TodoView >> children
TodoView >> renderOn:
```

A child is a whole view: it renders itself, has its own state, and has its own actions. An action from inside a child goes to that child, so `TodoForm >> add:` runs on the form, not on the todo view around it.

That makes a child a good home for a piece of a page with state of its own, like a form and its validation error:

```methods
TodoForm >> add:
TodoForm >> renderOn:
```

## Ids

Children get their ids from their parent: the second child of view `a8f3` is `a8f3-2`. `html render:` marks the child's HTML with its id, which is how the browser knows where to send its actions and where to put what comes back.

Make children once, when the view is made, and keep them in instance variables, so they keep their state from one render to the next.

## Watching

A view's watches stop at its children: each child watches what it reaches itself, and a page updates when anything any of them watches is committed.
