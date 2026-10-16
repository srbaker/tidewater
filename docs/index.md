---
layout: home

hero:
  name: Tidewater
  text: Live web pages, straight from your objects.
  tagline: Views are Smalltalk objects that render HTML. When anything commits a change to what a view shows, every page showing it updates itself.
  image:
    src: /wave.svg
    alt: Tidewater
  actions:
    - theme: brand
      text: Get started
      link: /guide/getting-started
    - theme: alt
      text: What is Tidewater?
      link: /guide/what-is-tidewater
    - theme: alt
      text: GitHub
      link: https://github.com/srbaker/tidewater

features:
  - title: The database is the state
    details: No API to design, no cache to keep in step, no client-side app. A view shows persistent objects, and the page follows them.
  - title: Every commit, every page
    details: A click, a script, a colleague in another session — whoever commits, every page showing those objects updates within a moment.
  - title: Just Smalltalk
    details: Views, actions and tests are plain classes and methods. Change a method and the pages showing it re-render.
  - title: Room to grow
    details: One gem serves a thousand open pages. Put a small front end before several gems for tens of thousands.
---

<div class="vp-doc" style="max-width: 688px; margin: 64px auto 0;">

## A whole app

```methods
CounterView >> renderOn:
CounterView >> actions
CounterView >> increment
```

Serve it, and open it in two browsers:

```smalltalk
(TwApp on: [CounterView on: (UserGlobals at: #TidewaterCounter)]) serveOn: 8080
```

Click `+` in one and both show the new count. Commit `counter increment` from a workspace, and both update again.

</div>
