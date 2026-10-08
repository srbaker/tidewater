Class {
	#name : 'TwApp',
	#superclass : 'Object',
	#instVars : [
		'view',
		'session',
		'subscribers',
		'rendered',
		'warnings'
	],
	#category : 'Tidewater-Core'
}

{ #category : 'instance creation' }
TwApp class >> on: aView [
	^ self on: aView in: (TwSession on: System)
]

{ #category : 'instance creation' }
TwApp class >> on: aView in: aSession [
	^ self new setView: aView session: aSession
]

{ #category : 'checking' }
TwApp >> checkForUnwatchedChanges [
	| html |
	warnings ifNil: [^ self].
	html := view render.
	html = rendered ifFalse: [
		warnings
			nextPutAll: view class name, ' changed without a watched object changing; watch more, or put it behind a TwRoot';
			lf].
	rendered := html
]

{ #category : 'streaming' }
TwApp >> eventFor: html [
	| lines event |
	lines := ReadStream on: html.
	event := WriteStream on: String new.
	[lines atEnd] whileFalse: [event nextPutAll: 'data: '; nextPutAll: (lines upTo: Character lf); lf].
	^ event lf; contents
]

{ #category : 'rendering' }
TwApp >> page [
	^ '<!DOCTYPE html><html><head><script src="/morphdom.js" defer></script><script src="/tidewater.js" defer></script></head><body><div tw-view>', view render, '</div></body></html>'
]

{ #category : 'handling' }
TwApp >> pageInto: aResponse [
	self checkForUnwatchedChanges.
	aResponse content: self page
]

{ #category : 'streaming' }
TwApp >> push [
	| event |
	rendered := view render.
	event := self eventFor: rendered.
	subscribers do: [:each | each write: event]
]

{ #category : 'handling' }
TwApp >> renderInto: aResponse [
	aResponse content: view render
]

{ #category : 'handling' }
TwApp >> router [
	^ Router new
		get: '/' do: [:request :response | self pageInto: response];
		get: '/events' do: [:request :response | self streamInto: response];
		get: '/:script' do: [:request :response :script | self script: script into: response];
		post: '/:action' do: [:request :response :action | self run: action asSymbol into: response];
		yourself
]

{ #category : 'handling' }
TwApp >> run: anAction into: aResponse [
	(view actions includes: anAction) ifFalse: [^ aResponse code: 404].
	session do: [view perform: anAction].
	self renderInto: aResponse
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

{ #category : 'serving' }
TwApp >> serve: aListener on: aPort [
	rendered := view render.
	session watch: view watches then: [self push].
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
TwApp >> setView: aView session: aSession [
	view := aView.
	session := aSession.
	subscribers := IdentitySet new
]

{ #category : 'streaming' }
TwApp >> stream: aSocket [
	subscribers add: aSocket.
	[aSocket readWillNotBlockWithin: -1] ensure: [subscribers remove: aSocket]
]

{ #category : 'streaming' }
TwApp >> streamInto: aResponse [
	aResponse
		contentType: 'text/event-stream';
		sendContentsBlock: [:socket | self stream: socket]
]

{ #category : 'checking' }
TwApp >> warnTo: aStream [
	warnings := aStream
]
