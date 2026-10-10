Class {
	#name : 'TwApp',
	#superclass : 'Object',
	#instVars : [
		'factory',
		'session',
		'views',
		'warnings',
		'scripts',
		'name',
		'relays'
	],
	#category : 'Tidewater-Core'
}

{ #category : 'instance creation' }
TwApp class >> on: aBlock [
	^ self on: aBlock in: (TwSession on: System)
]

{ #category : 'instance creation' }
TwApp class >> on: aBlock in: aSession [
	^ self new setFactory: aBlock session: aSession
]

{ #category : 'actions' }
TwApp >> action: aString of: aView [
	^ aView actions
		detect: [:each | each = aString asSymbol or: [each = (aString, ':') asSymbol]]
		ifNone: [nil]
]

{ #category : 'checking' }
TwApp >> checkForUnwatchedChanges [
	warnings ifNil: [^ self].
	views do: [:each | each checkForUnwatchedChangesTo: warnings]
]

{ #category : 'serving' }
TwApp >> listener [
	^ TwListener new
]

{ #category : 'accessing' }
TwApp >> name: aString [
	name := aString
]

{ #category : 'views' }
TwApp >> newViewId [
	| random id |
	random := HostRandom new.
	id := (1 to: 4) inject: '' into: [:each :index | each, (random integer printStringRadix: 16)].
	^ name ifNil: [id] ifNotNil: [name, '.', id]
]

{ #category : 'handling' }
TwApp >> openViewInto: aResponse [
	| view |
	self checkForUnwatchedChanges.
	view := factory value.
	view id: self newViewId.
	views at: view id put: view.
	session watch: view allWatches.
	aResponse content: (view documentWith: scripts)
]

{ #category : 'streaming' }
TwApp >> push [
	views do: [:each |
		each push.
		relays do: [:relay | relay write: each relayEvent]]
]

{ #category : 'streaming' }
TwApp >> relayInto: aResponse [
	aResponse
		contentType: 'text/event-stream';
		sendContentsBlock: [:socket |
			relays add: socket.
			[socket readWillNotBlockWithin: -1] ensure: [relays remove: socket]]
]

{ #category : 'handling' }
TwApp >> render: anId into: aResponse [
	aResponse content: ((self viewAt: anId) ifNil: [^ aResponse code: 404]) render
]

{ #category : 'handling' }
TwApp >> router [
	^ Router new
		get: '/' do: [:request :response | self openViewInto: response];
		get: '/events/:view' do: [:request :response :view | self stream: view into: response];
		get: '/views/:view' do: [:request :response :view | self render: view into: response];
		get: '/relay' do: [:request :response | self relayInto: response];
		get: '/:script' do: [:request :response :script | self script: script into: response];
		post: '/:view/:action' do: [:request :response :view :action | self run: action on: view with: request into: response];
		yourself
]

{ #category : 'handling' }
TwApp >> run: aString on: anId with: aRequest into: aResponse [
	| view action |
	view := (self viewAt: anId) ifNil: [^ aResponse code: 404].
	action := (self action: aString of: view) ifNil: [^ aResponse code: 404].
	[session do: [self send: action to: view from: aRequest]]
		on: TwConflict
		do: [:conflict | ^ aResponse code: 409].
	aResponse content: view render
]

{ #category : 'scripts' }
TwApp >> script: aPath [
	scripts add: aPath
]

{ #category : 'handling' }
TwApp >> script: aFilename into: aResponse [
	(self scripts includes: aFilename) ifFalse: [^ aResponse code: 404].
	aResponse content: (self scriptsDirectory / aFilename) contents
]

{ #category : 'scripts' }
TwApp >> scripts [
	^ scripts
]

{ #category : 'scripts' }
TwApp >> scriptsDirectory [
	^ (Rowan projectNamed: 'Tidewater') repositoryRoot / 'js'
]

{ #category : 'actions' }
TwApp >> send: anAction to: aView from: aRequest [
	anAction numArgs = 0 ifTrue: [^ aView perform: anAction].
	aView perform: anAction with: aRequest arguments
]

{ #category : 'serving' }
TwApp >> serve: aListener on: aPort [
	session whenChanged: [self push].
	aListener port: aPort; listenBacklog: 200; router: self router; run
]

{ #category : 'serving' }
TwApp >> serveOn: aPort [
	self serve: self listener on: aPort
]

{ #category : 'accessing' }
TwApp >> session [
	^ session
]

{ #category : 'initialization' }
TwApp >> setFactory: aBlock session: aSession [
	factory := aBlock.
	session := aSession.
	views := Dictionary new.
	relays := IdentitySet new.
	scripts := OrderedCollection with: 'morphdom.js' with: 'tidewater.js'
]

{ #category : 'handling' }
TwApp >> stream: anId into: aResponse [
	| view |
	view := views at: anId ifAbsent: [^ aResponse code: 404].
	aResponse
		contentType: 'text/event-stream';
		sendContentsBlock: [:socket | view stream: socket]
]

{ #category : 'views' }
TwApp >> viewAt: anId [
	^ (views at: (anId copyUpTo: $-) ifAbsent: [^ nil]) viewAt: anId
]

{ #category : 'checking' }
TwApp >> warnTo: aStream [
	warnings := aStream
]
