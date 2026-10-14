Class {
	#name : 'TwView',
	#superclass : 'Object',
	#instVars : [
		'id',
		'sockets',
		'rendered',
		'history'
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

{ #category : 'watching' }
TwView >> code [
	| dictionaries class |
	dictionaries := OrderedCollection new.
	class := self class.
	[dictionaries add: (class persistentMethodDictForEnv: 0). class == TwView] whileFalse: [class := class superclass].
	self children do: [:each | dictionaries addAll: each code].
	^ dictionaries select: [:each | each notNil]
]

{ #category : 'rendering' }
TwView >> documentWith: scripts [
	| html |
	self remember: self render.
	html := WriteStream on: String new.
	html nextPutAll: '<!DOCTYPE html><html><head>'.
	scripts do: [:each | html nextPutAll: '<script src="/', each, '" defer></script>'].
	^ html nextPutAll: '</head><body><div tw-view="', id, '">', rendered, '</div></body></html>'; contents
]

{ #category : 'rendering' }
TwView >> escape: aString [
	| html |
	html := WriteStream on: String new.
	aString do: [:each | | special |
		special := '&<>"''' indexOf: each.
		special = 0
			ifTrue: [html nextPut: each]
			ifFalse: [html nextPutAll: (#('&amp;' '&lt;' '&gt;' '&quot;' '&#39;') at: special)]].
	^ html contents
]

{ #category : 'streaming' }
TwView >> eventFor: html [
	| lines event |
	lines := ReadStream on: html.
	event := WriteStream on: String new.
	[lines atEnd] whileFalse: [event nextPutAll: 'data: '; nextPutAll: (lines upTo: Character lf); lf].
	^ event lf; contents
]

{ #category : 'history' }
TwView >> history [
	^ history
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
	sockets := IdentitySet new.
	history := OrderedCollection new
]

{ #category : 'watching' }
TwView >> isWatchable: anObject [
	^ (anObject isSpecial
		or: [anObject isInvariant
		or: [anObject isBehavior
		or: [anObject isKindOf: TwView]]]) not
]

{ #category : 'streaming' }
TwView >> push [
	| event |
	self remember: self render.
	event := self eventFor: rendered.
	sockets do: [:each | each write: event]
]

{ #category : 'streaming' }
TwView >> relayEvent [
	^ 'event: ', id, (String with: Character lf), (self eventFor: rendered)
]

{ #category : 'history' }
TwView >> remember: html [
	rendered := html.
	(history notEmpty and: [history last = html]) ifTrue: [^ self].
	history add: html.
	history size > 50 ifTrue: [history removeFirst]
]

{ #category : 'rendering' }
TwView >> render [
	^ self subclassResponsibility
]

{ #category : 'composing' }
TwView >> render: aView [
	^ '<div tw-view="', (aView id ifNil: ['']), '">', aView render, '</div>'
]

{ #category : 'watching' }
TwView >> slotsOf: anObject [
	| slots |
	slots := (1 to: anObject class instSize) collect: [:index | anObject instVarAt: index].
	(anObject class isIndexable and: [anObject class isBytes not]) ifFalse: [^ slots].
	^ slots, ((1 to: anObject basicSize) collect: [:index | anObject basicAt: index])
]

{ #category : 'streaming' }
TwView >> stream: aSocket [
	sockets add: aSocket.
	self remember: self render.
	aSocket write: 'retry: 1000', (String with: Character lf), (self eventFor: rendered).
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
	"By default, everything this view reaches, stopping at aggregate roots and other views."

	| found pending |
	found := IdentitySet new.
	pending := ((TwView instSize + 1) to: self class instSize) collect: [:index | self instVarAt: index].
	pending := pending asOrderedCollection.
	[pending notEmpty and: [found size < 1000]] whileTrue: [| each |
		each := pending removeFirst.
		((self isWatchable: each) and: [(found includes: each) not]) ifTrue: [
			found add: each.
			(each isKindOf: TwRoot) ifFalse: [pending addAll: (self slotsOf: each)]]].
	^ found asArray
]
