# Inside Tidewater

## A visit

1. A browser asks for `/`. The app makes a view with its factory, gives it an unguessable id, and keeps it.
2. The view renders, and the page is sent with that HTML and Tidewater's scripts.
3. The page opens an event stream to `/events/<id>`. The view sends its current render down it, and keeps the stream for later.
4. The gem adds everything the view watches, and its code, to GemStone's **notify set**.

## A change

1. Someone commits a change to an object in the notify set, from anywhere: an action in this gem, another gem, a workspace.
2. GemStone marks the object as signaled. The gem checks for signaled objects every 100ms.
3. When there are some, it aborts, to see the new state, and every view renders again.
4. Each render goes down its view's event streams, and the browser patches the page with it.
5. Each view's watches are taken again, so anything new it reaches is watched from then on.

## An action

1. A click posts to `/<id>/<action>`, with any form fields.
2. The app checks the action is one the view lists, then aborts, runs it, and commits, retrying on a conflict.
3. The view renders, and the HTML goes back as the post's answer, so the page that acted updates at once.
4. The commit comes round through the notify set like anyone else's, and every other page updates.

## Housekeeping

- Views no browser has had a stream open to for a minute are forgotten.
- The gem's own listener aborts as it waits for connections, rather than committing, so it never holds a stale view of the world, and serving gems never conflict with each other.
- A gem has one transaction, shared by all its processes, so an abort in one would throw away an action half done in another. Actions, refreshes and pushes take turns.
