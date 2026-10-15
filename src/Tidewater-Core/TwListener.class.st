Class {
	#name : 'TwListener',
	#superclass : 'HttpListener',
	#category : 'Tidewater-Core'
}

{ #category : 'Web Server' }
TwListener >> acceptWaiting [
	"Abort before each connection, so every request sees everything committed before it arrived."

	[socket readWillNotBlock] whileTrue: [
		System sessionCacheStatAt: 0 incrementBy: 1.
		System abortTransaction.
		[:each | self mainLoopBody: each] forkWith: {socket accept}]
]

{ #category : 'Web Server' }
TwListener >> mainLoop [
	"Like HttpListener's, but abort to see other sessions' commits instead of committing:
	 Tidewater commits its own actions, and committing here collides with other worker gems."

	[[true] whileTrue: [
		System abortTransaction.
		([socket readWillNotBlockWithin: 60000] on: Error do: [:ex | ex return: false])
			ifTrue: [self acceptWaiting]]]
		ensure: [
			socket close.
			socket := nil.
			server shutdown]
]
