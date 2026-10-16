# State

Every visit gets a view of its own, made fresh by the app's **factory** block:

```smalltalk
(TwApp on: [TodoView on: (UserGlobals at: #TidewaterTodos)]) serveOn: 8080
```

So there are two kinds of state, and they live in different places:

- **The page's own state** lives in the view's instance variables: what was typed into a filter, a validation error, which tab is open. It belongs to one page, and goes when the page does.
- **Shared state** lives in persistent objects the view points to: the todo list, the counter. Everyone sees it, it survives restarts, and every change to it reaches every page showing it.

The todo view has both:

```methods
TodoView >> setList:
TodoView >> visibleItems
```

`list` is shared; `filter` is this page's own. Typing in the filter changes only `filter`, so only this page re-renders. Adding an item changes `list`, so every page does — each still filtered its own way.

## Keeping views

A view is kept, by an unguessable id, while its page is open. Once no browser has had its event stream open for a minute, it's forgotten. A page that comes back after that, or after the server restarts, reloads itself onto a new view.

Views aren't committed. They live in the serving gem's memory, so their instance variables are fine for anything about the page, and the wrong place for anything that matters after it closes.
