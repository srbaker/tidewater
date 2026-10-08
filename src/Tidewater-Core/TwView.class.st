Class {
	#name : 'TwView',
	#superclass : 'Object',
	#instVars : [
		'id',
		'sockets',
		'rendered'
	],
	#category : 'Tidewater-Core'
}

{ #category : 'instance creation' }
TwView class >> new [
	^ super new initialize
]

{ #category : 'actions' }
TwView >> actions [
	^ #()
]

{ #category : 'checking' }
TwView >> checkForUnwatchedChangesTo: aStream [
	| html |
	html := self render.
	html = rendered ifFalse: [
		aStream
			nextPutAll: self class name, ' changed without a watched object changing; watch more, or put it behind a TwRoot';
			lf].
	rendered := html
]

{ #category : 'rendering' }
TwView >> document [
	rendered := self render.
	^ '<!DOCTYPE html><html><head><script src="/morphdom.js" defer></script><script src="/tidewater.js" defer></script></head><body><div tw-view="', id, '">', rendered, '</div></body></html>'
]

{ #category : 'streaming' }
TwView >> eventFor: html [
	| lines event |
	lines := ReadStream on: html.
	event := WriteStream on: String new.
	[lines atEnd] whileFalse: [event nextPutAll: 'data: '; nextPutAll: (lines upTo: Character lf); lf].
	^ event lf; contents
]

{ #category : 'accessing' }
TwView >> id [
	^ id
]

{ #category : 'accessing' }
TwView >> id: aString [
	id := aString
]

{ #category : 'initialization' }
TwView >> initialize [
	sockets := IdentitySet new
]

{ #category : 'streaming' }
TwView >> push [
	| event |
	rendered := self render.
	event := self eventFor: rendered.
	sockets do: [:each | each write: event]
]

{ #category : 'rendering' }
TwView >> render [
	^ self subclassResponsibility
]

{ #category : 'streaming' }
TwView >> stream: aSocket [
	sockets add: aSocket.
	[aSocket readWillNotBlockWithin: -1] ensure: [sockets remove: aSocket]
]

{ #category : 'watching' }
TwView >> watches [
	^ #()
]
