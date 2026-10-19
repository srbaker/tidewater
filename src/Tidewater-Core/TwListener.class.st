Class {
	#name : 'TwListener',
	#superclass : 'HttpListener',
	#instVars : [
		'session'
	],
	#category : 'Tidewater-Core'
}

{ #category : 'instance creation' }
TwListener class >> on: aSession [
	^ self new setSession: aSession
]

{ #category : 'Web Server' }
TwListener >> acceptWaiting [
	"Refresh before each connection, so every request sees everything committed before it arrived."

	[socket readWillNotBlock] whileTrue: [
		System sessionCacheStatAt: 0 incrementBy: 1.
		session refresh.
		[:each | self mainLoopBody: each] forkWith: {socket accept}]
]

{ #category : 'Web Server' }
TwListener >> mainLoop [
	"Like HttpListener's, but refresh to see other sessions' commits instead of committing:
	 Tidewater commits its own actions, and committing here collides with other worker gems."

	[[true] whileTrue: [
		session refresh.
		([socket readWillNotBlockWithin: 60000] on: Error do: [:ex | ex return: false])
			ifTrue: [self acceptWaiting]]]
		ensure: [
			socket close.
			socket := nil.
			server shutdown]
]

{ #category : 'accessing' }
TwListener >> session [
	^ session
]

{ #category : 'initialization' }
TwListener >> setSession: aSession [
	session := aSession
]
