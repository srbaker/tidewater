Class {
	#name : 'TwAppTest',
	#superclass : 'TestCase',
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
TwAppTest >> get: aPath [
	^ HttpRequest fromString: 'GET ', aPath, ' HTTP/1.1', self crlf, self crlf
]

{ #category : 'private' }
TwAppTest >> post: aPath [
	^ HttpRequest fromString: 'POST ', aPath, ' HTTP/1.1', self crlf, 'Content-Length: 0', self crlf, self crlf
]

{ #category : 'private' }
TwAppTest >> routerFor: aView [
	^ self routerFor: aView in: TwMockSession new
]

{ #category : 'private' }
TwAppTest >> routerFor: aView in: aSession [
	| listener |
	listener := TwMockListener new.
	(TwApp on: aView in: aSession) serve: listener on: 8888.
	^ listener router
]

{ #category : 'tests' }
TwAppTest >> testDoesNotWarnAboutPushedChanges [
	| counter session app listener warnings |
	counter := TwCounter new.
	session := TwMockSession new.
	app := TwApp on: (TwCounterView on: counter) in: session.
	warnings := WriteStream on: String new.
	app warnTo: warnings.
	listener := TwMockListener new.
	app serve: listener on: 8888.
	counter increment.
	session change.
	listener router handle: (self get: '/').
	self assert: warnings contents isEmpty
]

{ #category : 'tests' }
TwAppTest >> testListensWithRoomForBurstsOfConnections [
	| listener |
	listener := TwMockListener new.
	(TwApp on: (TwCounterView on: TwCounter new) in: TwMockSession new) serve: listener on: 8888.
	self assert: listener listenBacklog equals: 200
]

{ #category : 'tests' }
TwAppTest >> testPostingAnActionUpdatesTheView [
	| counter view |
	counter := TwCounter new.
	view := TwCounterView on: counter.
	self assert: (self bodyOf: ((self routerFor: view) handle: (self post: '/increment'))) equals: view render.
	self assert: counter count equals: 1
]

{ #category : 'tests' }
TwAppTest >> testPostingAnUnknownActionIsNotFound [
	| router |
	router := self routerFor: (TwCounterView on: TwCounter new).
	self assert: (router handle: (self post: '/render')) code equals: 404
]

{ #category : 'tests' }
TwAppTest >> testPrefixesEveryLineOfAnEvent [
	| lf app |
	lf := String with: Character lf.
	app := TwApp on: (TwMockView rendering: '') in: TwMockSession new.
	self
		assert: (app eventFor: '<p>', lf, 'one', lf, '</p>')
		equals: 'data: <p>', lf, 'data: one', lf, 'data: </p>', lf, lf
]

{ #category : 'tests' }
TwAppTest >> testPushesWhenAWatchedObjectChanges [
	| view app session listener socket |
	session := TwMockSession new.
	view := TwCounterView on: TwCounter new.
	app := TwApp on: view in: session.
	listener := TwMockListener new.
	app serve: listener on: 8888.
	socket := TwMockSocket whileOpen: [session change].
	(listener router handle: (self get: '/events')) sendResponseOn: socket.
	self assert: socket written last equals: (app eventFor: view render)
]

{ #category : 'tests' }
TwAppTest >> testRunsActionsInATransaction [
	| session |
	session := TwMockSession new.
	(self routerFor: (TwCounterView on: TwCounter new) in: session) handle: (self post: '/increment').
	self assert: session hasRun
]

{ #category : 'tests' }
TwAppTest >> testServesItsScripts [
	| router directory |
	router := self routerFor: (TwCounterView on: TwCounter new).
	directory := (Rowan projectNamed: 'Tidewater') repositoryRoot / 'js'.
	#('tidewater.js' 'morphdom.js') do: [:each |
		self assert: (self bodyOf: (router handle: (self get: '/', each))) equals: (directory / each) contents]
]

{ #category : 'tests' }
TwAppTest >> testServesItsViewInAPage [
	| view |
	view := TwCounterView on: TwCounter new.
	self
		assert: (self bodyOf: ((self routerFor: view) handle: (self get: '/')))
		equals: '<!DOCTYPE html><html><head><script src="/morphdom.js" defer></script><script src="/tidewater.js" defer></script></head><body><div tw-view>', view render, '</div></body></html>'
]

{ #category : 'tests' }
TwAppTest >> testServesItsViewWithAListenerOnAPort [
	| view listener |
	view := TwCounterView on: TwCounter new.
	listener := TwMockListener new.
	(TwApp on: view in: TwMockSession new) serve: listener on: 8888.
	self assert: listener port equals: 8888.
	self assert: listener isRunning.
	self assert: ((self bodyOf: (listener router handle: (self get: '/'))) includesString: view render)
]

{ #category : 'tests' }
TwAppTest >> testServesNoOtherFiles [
	| router |
	router := self routerFor: (TwCounterView on: TwCounter new).
	self assert: (router handle: (self get: '/tidewater.spec.js')) code equals: 404.
	self assert: (router handle: (self get: '/../package.json')) code equals: 404
]

{ #category : 'tests' }
TwAppTest >> testStopsStreamingWhenTheClientLeaves [
	| router socket |
	router := self routerFor: (TwCounterView on: TwCounter new).
	socket := TwMockSocket whileOpen: [].
	(router handle: (self get: '/events')) sendResponseOn: socket.
	router handle: (self post: '/increment').
	self assert: socket written size equals: 1
]

{ #category : 'tests' }
TwAppTest >> testStreamsTheViewWhenAnActionRuns [
	| view router socket |
	view := TwCounterView on: TwCounter new.
	router := self routerFor: view.
	socket := TwMockSocket whileOpen: [router handle: (self post: '/increment')].
	(router handle: (self get: '/events')) sendResponseOn: socket.
	self assert: (socket written first includesString: 'Content-Type: text/event-stream').
	self assert: socket written last equals: 'data: ', view render, (String with: Character lf with: Character lf)
]

{ #category : 'tests' }
TwAppTest >> testUsesTheRealSessionByDefault [
	| session |
	session := (TwApp on: (TwCounterView on: TwCounter new)) session.
	self assert: session system identical: System.
	self assert: session notifications identical: ObjectsCommittedNotification
]

{ #category : 'tests' }
TwAppTest >> testWarnsWhenAPageShowsAChangeThatWasNeverPushed [
	| counter app listener warnings |
	counter := TwCounter new.
	app := TwApp on: (TwCounterView on: counter) in: TwMockSession new.
	warnings := WriteStream on: String new.
	app warnTo: warnings.
	listener := TwMockListener new.
	app serve: listener on: 8888.
	counter increment.
	listener router handle: (self get: '/').
	self assert: (warnings contents includesString: 'TwCounterView changed without a watched object changing')
]

{ #category : 'tests' }
TwAppTest >> testWatchesWhatItsViewWatches [
	| counter session |
	counter := TwCounter new.
	session := TwMockSession new.
	self routerFor: (TwCounterView on: counter) in: session.
	self assert: session watched asArray equals: {counter}
]
