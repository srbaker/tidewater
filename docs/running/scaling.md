# Scaling out

One gem serves an app comfortably to a thousand or so open pages. Beyond that, run several **worker** gems behind Tidewater's **front end**, a small Node server in `front/` that holds every browser's connection:

```sh
bin/serve todo 8901 w1 &
bin/serve todo 8902 w2 &
node front/front.js 8080 w1=http://localhost:8901 w2=http://localhost:8902
```

With four workers, a commit reached each of 10,000 open pages within 350ms.

## Workers

A worker is an ordinary app with a name:

```smalltalk
(TwApp on: [TodoView on: (UserGlobals at: #TidewaterTodos)]) name: 'w1'; serveOn: 8901
```

The name prefixes its views' ids, as in `w1.a8f3`, so the front end knows which worker each view lives on.

## The front end

- **New pages** go to the workers in turn.
- **Actions** and **history** go to the worker named in the view's id.
- **Event streams** stay with the front end. It keeps one relay stream open to each worker, which carries every render of every view, and hands each to the pages showing that view.

So a worker holds one connection to the front end, however many pages are open, and each commit costs it one render per view rather than one write per browser.

If a worker goes away, the front end tells its pages, and they reload onto a worker that's still there.

## Measuring

`load/fanout.js` opens pages on a counter app, alone or behind the front end, commits, and measures how long each change takes to reach every page:

```sh
node load/fanout.js http://localhost:8080 100 1000 10000
```

`load/concurrent.js` checks that clicks racing other sessions' commits all land.
