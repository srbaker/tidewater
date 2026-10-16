# Getting started

## You need

- **GemStone/S 64 Bit 3.7** with the **Rowan 3** extent (`$GEMSTONE/bin/extent0.rowan3.dbf`). Jasper, GemTalk's extension for VS Code, is the friendliest way to make and run one.
- **[WebGS](https://github.com/jgfoster/WebGS)**, installed into the stone with its `install.sh`.
- A shell with the GemStone environment set: `GEMSTONE` and friends. Jasper's *Open Terminal* does this.

## Load Tidewater

Clone Tidewater next to your other projects:

```sh
git clone git@github.com:srbaker/tidewater.git
```

Then load it with Rowan, from Jasper or topaz:

```smalltalk
(Rowan projectFromUrl: 'file:/path/to/projects/tidewater/rowan/specs/Tidewater.ston'
	projectsHome: '/path/to/projects') load.
System commitTransaction.
```

The examples are a project of their own. Load them the same way:

```smalltalk
(Rowan projectFromUrl: 'file:/path/to/projects/tidewater/examples/rowan/specs/TidewaterExamples.ston'
	projectsHome: '/path/to/projects') load.
System commitTransaction.
```

## Run an example

```sh
bin/serve todo 8080      # or: bin/serve counter 8080
```

Open `http://localhost:8080/` in a couple of browsers, and add an item in one. The script logs in as `DataCurator` to `gs64stone`; set `TIDEWATER_STONE_PASSWORD` and `TIDEWATER_STONE` if yours differ.

`bin/serve` runs its own topaz gem, which keeps serving until you stop it. The app it starts is one line:

```smalltalk
(TwApp on: [TodoView on: (UserGlobals at: #TidewaterTodos)]) serveOn: 8080
```

## Change it while it runs

With the todo app open, change `TodoView >> renderOn:` in Jasper and commit. Every open page re-renders with the new method: a view's code is watched like its objects.

## Your own app

1. Keep your model as plain persistent objects. Make the ones that own others subclass [`TwRoot`](./watching#aggregate-roots).
2. Subclass `TwView`, implement `renderOn:`, and list its `actions`.
3. Serve it with `TwApp on: [YourView on: yourModel]`.

The guide goes through each of these, starting with [views](./views).
