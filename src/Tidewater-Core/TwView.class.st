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

{ #category : 'watching' }
TwView >> allWatches [
	^ self children
		inject: self watches asOrderedCollection
		into: [:all :each | all addAll: each allWatches; yourself]
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

{ #category : 'composing' }
TwView >> children [
	^ #()
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
	id := aString.
	self children keysAndValuesDo: [:index :each | each id: id, '-', index printString]
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

{ #category : 'composing' }
TwView >> render: aView [
	^ '<div tw-view="', (aView id ifNil: ['']), '">', aView render, '</div>'
]

{ #category : 'streaming' }
TwView >> stream: aSocket [
	sockets add: aSocket.
	rendered := self render.
	aSocket write: (self eventFor: rendered).
	[aSocket readWillNotBlockWithin: -1] ensure: [sockets remove: aSocket]
]

{ #category : 'composing' }
TwView >> viewAt: anId [
	id = anId ifTrue: [^ self].
	self children do: [:each | (each viewAt: anId) ifNotNil: [:found | ^ found]].
	^ nil
]

{ #category : 'watching' }
TwView >> watches [
	^ #()
]
