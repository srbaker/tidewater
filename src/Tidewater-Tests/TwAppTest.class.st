Class {
	#name : 'TwAppTest',
	#superclass : 'TestCase',
	#instVars : [
		'session'
	],
	#category : 'Tidewater-Tests'
}

{ #category : 'private' }
TwAppTest >> bodyOf: aResponse [
	| message |
	message := aResponse printString.
	^ message copyFrom: (message indexOfSubCollection: self crlf, self crlf) + 4 to: message size - 2
]

{ #category : 'private' }
TwAppTest >> crlf [
	^ String with: Character cr with: Character lf
]

{ #category : 'private' }
TwAppTest >> event: html [
	^ 'data: ', html, (String with: Character lf with: Character lf)
]

{ #category : 'private' }
TwAppTest >> get: aPath [
	^ HttpRequest fromString: 'GET ', aPath, ' HTTP/1.1', self crlf, self crlf
]

{ #category : 'private' }
TwAppTest >> openViewWith: aRouter [
	| html start |
	html := self bodyOf: (aRouter handle: (self get: '/')).
	start := (html indexOfSubCollection: 'tw-view="') + 9.
	^ html copyFrom: start to: (html indexOf: $" startingAt: start) - 1
]

{ #category : 'private' }
TwAppTest >> post: aPath [
	^ HttpRequest fromString: 'POST ', aPath, ' HTTP/1.1', self crlf, 'Content-Length: 0', self crlf, self crlf
]

{ #category : 'private' }
TwAppTest >> post: aPath fields: aString [
	^ HttpRequest fromString: 'POST ', aPath, ' HTTP/1.1', self crlf,
		'Content-Type: application/x-www-form-urlencoded', self crlf,
		'Content-Length: ', aString size printString, self crlf, self crlf, aString
]

{ #category : 'private' }
TwAppTest >> routerFor: anApp [
	| listener |
	listener := TwMockListener new.
	anApp serve: listener on: 8888.
	^ listener router
]

{ #category : 'private' }
TwAppTest >> routerOn: aCounter [
	^ self routerFor: (TwApp on: [TwCounterView on: aCounter] in: session)
]

{ #category : 'running' }
TwAppTest >> setUp [
	session := TwMockSession new
]

{ #category : 'tests' }
TwAppTest >> testDoesNotWarnAboutPushedChanges [
	| counter app warnings router |
	counter := TwCounter new.
	app := TwApp on: [TwCounterView on: counter] in: session.
	warnings := WriteStream on: String new.
	app warnTo: warnings.
	router := self routerFor: app.
	self openViewWith: router.
	counter increment.
	session change.
	self openViewWith: router.
	self assert: warnings contents isEmpty
]

{ #category : 'tests' }
TwAppTest >> testGivesEachVisitAFreshViewWithAnUnguessableId [
	| views router one two |
	views := 0.
	router := self routerFor: (TwApp on: [views := views + 1. TwCounterView on: TwCounter new] in: session).
	one := self openViewWith: router.
	two := self openViewWith: router.
	self assert: views equals: 2.
	self deny: one = two.
	self assert: one size >= 20
]

{ #category : 'tests' }
TwAppTest >> testPassesPostedFieldsToActionsThatTakeThem [
	| list router id |
	list := TwTodoList new.
	router := self routerFor: (TwApp on: [TwTodoForm on: list] in: session).
	id := self openViewWith: router.
	router handle: (self post: '/', id, '/add' fields: 'item=milk').
	self assert: list items asArray equals: #('milk')
]

{ #category : 'tests' }
TwAppTest >> testPushesEveryViewWhenAWatchedObjectChanges [
	| counter router one two first second |
	counter := TwCounter new.
	router := self routerOn: counter.
	one := self openViewWith: router.
	two := self openViewWith: router.
	second := TwMockSocket whileOpen: [counter increment. session change].
	first := TwMockSocket whileOpen: [(router handle: (self get: '/events/', two)) sendResponseOn: second].
	(router handle: (self get: '/events/', one)) sendResponseOn: first.
	self assert: first written last equals: (self event: (TwCounterView on: counter) render).
	self assert: second written last equals: (self event: (TwCounterView on: counter) render)
]

{ #category : 'tests' }
TwAppTest >> testRunsActionsOnChildViews [
	| counter router id |
	counter := TwCounter new.
	router := self routerFor: (TwApp on: [TwMockView rendering: '' children: {TwCounterView on: counter}] in: session).
	id := self openViewWith: router.
	router handle: (self post: '/', id, '-1/increment').
	self assert: counter count equals: 1
]

{ #category : 'tests' }
TwAppTest >> testRunsAnActionOnItsViewInATransaction [
	| counter router id |
	counter := TwCounter new.
	router := self routerOn: counter.
	id := self openViewWith: router.
	self
		assert: (self bodyOf: (router handle: (self post: '/', id, '/increment')))
		equals: (TwCounterView on: counter) render.
	self assert: counter count equals: 1.
	self assert: session hasRun
]

{ #category : 'tests' }
TwAppTest >> testServesItsScripts [
	| router directory |
	router := self routerOn: TwCounter new.
	directory := (Rowan projectNamed: 'Tidewater') repositoryRoot / 'js'.
	#('tidewater.js' 'morphdom.js') do: [:each |
		self assert: (self bodyOf: (router handle: (self get: '/', each))) equals: (directory / each) contents]
]

{ #category : 'tests' }
TwAppTest >> testServesNoOtherFiles [
	| router |
	router := self routerOn: TwCounter new.
	self assert: (router handle: (self get: '/tidewater.spec.js')) code equals: 404.
	self assert: (router handle: (self get: '/../package.json')) code equals: 404
]

{ #category : 'tests' }
TwAppTest >> testServesWithAListenerOnAPort [
	| listener |
	listener := TwMockListener new.
	(TwApp on: [TwCounterView on: TwCounter new] in: session) serve: listener on: 8888.
	self assert: listener port equals: 8888.
	self assert: listener listenBacklog equals: 200.
	self assert: listener isRunning
]

{ #category : 'tests' }
TwAppTest >> testStreamsToItsView [
	| counter router id socket |
	counter := TwCounter new.
	router := self routerOn: counter.
	id := self openViewWith: router.
	socket := TwMockSocket whileOpen: [counter increment. session change].
	(router handle: (self get: '/events/', id)) sendResponseOn: socket.
	self assert: (socket written first includesString: 'Content-Type: text/event-stream').
	self assert: socket written last equals: (self event: (TwCounterView on: counter) render)
]

{ #category : 'tests' }
TwAppTest >> testUnknownActionsAndViewsAreNotFound [
	| router id |
	router := self routerOn: TwCounter new.
	id := self openViewWith: router.
	self assert: (router handle: (self post: '/', id, '/render')) code equals: 404.
	self assert: (router handle: (self post: '/nope/increment')) code equals: 404.
	self assert: (router handle: (self get: '/events/nope')) code equals: 404
]

{ #category : 'tests' }
TwAppTest >> testUsesTheRealSessionByDefault [
	| default |
	default := (TwApp on: [TwCounterView on: TwCounter new]) session.
	self assert: default system identical: System.
	self assert: default notifications identical: ObjectsCommittedNotification
]

{ #category : 'tests' }
TwAppTest >> testWarnsWhenAViewShowsAChangeThatWasNeverPushed [
	| counter app warnings router |
	counter := TwCounter new.
	app := TwApp on: [TwCounterView on: counter] in: session.
	warnings := WriteStream on: String new.
	app warnTo: warnings.
	router := self routerFor: app.
	self openViewWith: router.
	counter increment.
	self openViewWith: router.
	self assert: (warnings contents includesString: 'TwCounterView changed without a watched object changing')
]

{ #category : 'tests' }
TwAppTest >> testWatchesWhatChildViewsWatch [
	| counter |
	counter := TwCounter new.
	self openViewWith: (self routerFor: (TwApp on: [TwMockView rendering: '' children: {TwCounterView on: counter}] in: session)).
	self assert: session watched asArray equals: {counter}
]

{ #category : 'tests' }
TwAppTest >> testWatchesWhatEachViewWatches [
	| counter |
	counter := TwCounter new.
	self openViewWith: (self routerOn: counter).
	self assert: session watched asArray equals: {counter}
]
