Class {
	#name : 'TwApp',
	#superclass : 'Object',
	#instVars : [
		'factory',
		'session',
		'views',
		'warnings'
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
TwApp >> newViewId [
	| random |
	random := HostRandom new.
	^ (1 to: 4) inject: '' into: [:id :each | id, (random integer printStringRadix: 16)]
]

{ #category : 'handling' }
TwApp >> openViewInto: aResponse [
	| view |
	self checkForUnwatchedChanges.
	view := factory value.
	view id: self newViewId.
	views at: view id put: view.
	session watch: view watches.
	aResponse content: view document
]

{ #category : 'streaming' }
TwApp >> push [
	views do: [:each | each push]
]

{ #category : 'handling' }
TwApp >> router [
	^ Router new
		get: '/' do: [:request :response | self openViewInto: response];
		get: '/events/:view' do: [:request :response :view | self stream: view into: response];
		get: '/:script' do: [:request :response :script | self script: script into: response];
		post: '/:view/:action' do: [:request :response :view :action | self run: action on: view with: request into: response];
		yourself
]

{ #category : 'handling' }
TwApp >> run: aString on: anId with: aRequest into: aResponse [
	| view action |
	view := views at: anId ifAbsent: [^ aResponse code: 404].
	action := (self action: aString of: view) ifNil: [^ aResponse code: 404].
	session do: [self send: action to: view from: aRequest].
	aResponse content: view render
]

{ #category : 'handling' }
TwApp >> script: aFilename into: aResponse [
	(self scripts includes: aFilename) ifFalse: [^ aResponse code: 404].
	aResponse content: (self scriptsDirectory / aFilename) contents
]

{ #category : 'scripts' }
TwApp >> scripts [
	^ #('morphdom.js' 'tidewater.js')
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
	self serve: HttpListener new on: aPort
]

{ #category : 'accessing' }
TwApp >> session [
	^ session
]

{ #category : 'initialization' }
TwApp >> setFactory: aBlock session: aSession [
	factory := aBlock.
	session := aSession.
	views := Dictionary new
]

{ #category : 'handling' }
TwApp >> stream: anId into: aResponse [
	| view |
	view := views at: anId ifAbsent: [^ aResponse code: 404].
	aResponse
		contentType: 'text/event-stream';
		sendContentsBlock: [:socket | view stream: socket]
]

{ #category : 'checking' }
TwApp >> warnTo: aStream [
	warnings := aStream
]
