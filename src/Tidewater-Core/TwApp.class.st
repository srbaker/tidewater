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
		'relays',
		'clock'
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

{ #category : 'views' }
TwApp >> clock: aBlock [
	clock := aBlock
]

{ #category : 'handling' }
TwApp >> history: anId into: aResponse [
	| view |
	view := (self viewAt: anId) ifNil: [^ aResponse code: 404].
	aResponse
		contentType: 'application/json';
		content: view history asArray asJson
]

{ #category : 'serving' }
TwApp >> listener [
	^ TwListener on: session
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
	self sweep; checkForUnwatchedChanges.
	view := factory value.
	view id: self newViewId.
	views at: view id put: view.
	session watch: view allWatches, view code.
	aResponse content: (view documentWith: (scripts collect: [:each | each basename]))
]

{ #category : 'streaming' }
TwApp >> push [
	self sweep.
	views do: [:each |
		each push.
		session watch: each allWatches.
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
		get: '/history/:view' do: [:request :response :view | self history: view into: response];
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
TwApp >> script: aFile [
	scripts add: aFile
]

{ #category : 'handling' }
TwApp >> script: aName into: aResponse [
	| file |
	file := scripts detect: [:each | each basename = aName] ifNone: [^ aResponse code: 404].
	aResponse content: file contents
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
	scripts := OrderedCollection with: self scriptsDirectory / 'morphdom.js' with: self scriptsDirectory / 'tidewater.js'.
	clock := [Time millisecondClockValue]
]

{ #category : 'handling' }
TwApp >> stream: anId into: aResponse [
	| view |
	view := views at: anId ifAbsent: [nil].
	aResponse
		contentType: 'text/event-stream';
		sendContentsBlock: [:socket |
			view
				ifNil: [socket write: 'event: gone', (String with: Character lf), 'data: ', (String with: Character lf with: Character lf)]
				ifNotNil: [view stream: socket]]
]

{ #category : 'views' }
TwApp >> sweep [
	"Forget views that have had no open stream for a minute."

	views := views reject: [:each | each isIdleSince: clock value - 60000]
]

{ #category : 'views' }
TwApp >> viewAt: anId [
	^ (views at: (anId copyUpTo: $-) ifAbsent: [^ nil]) viewAt: anId
]

{ #category : 'checking' }
TwApp >> warnTo: aStream [
	warnings := aStream
]
