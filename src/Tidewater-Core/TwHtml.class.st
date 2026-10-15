Class {
	#name : 'TwHtml',
	#superclass : 'Object',
	#instVars : [
		'stream'
	],
	#category : 'Tidewater-Core'
}

{ #category : 'instance creation' }
TwHtml class >> new [
	^ super new initialize
]

{ #category : 'elements' }
TwHtml >> a: content [
	self element: 'a' with: content
]

{ #category : 'elements' }
TwHtml >> a: attributes with: content [
	self element: 'a' attributes: attributes with: content
]

{ #category : 'private' }
TwHtml >> attributeNamed: aKey [
	| events |
	events := Dictionary new
		at: #onClick put: 'tw-click';
		at: #onSubmit put: 'tw-submit';
		at: #onInput put: 'tw-input';
		at: #debounce put: 'tw-debounce';
		at: #hook put: 'tw-hook';
		yourself.
	^ events at: aKey asSymbol ifAbsent: [
		(aKey size > 2 and: [(aKey beginsWith: 'on') and: [(aKey at: 3) isUppercase]])
			ifTrue: [self error: 'Tidewater knows no event named ', aKey printString].
		aKey asString]
]

{ #category : 'elements' }
TwHtml >> button: content [
	self element: 'button' with: content
]

{ #category : 'elements' }
TwHtml >> button: attributes with: content [
	self element: 'button' attributes: attributes with: content
]

{ #category : 'writing' }
TwHtml >> contents [
	^ stream contents
]

{ #category : 'elements' }
TwHtml >> div: content [
	self element: 'div' with: content
]

{ #category : 'elements' }
TwHtml >> div: attributes with: content [
	self element: 'div' attributes: attributes with: content
]

{ #category : 'writing' }
TwHtml >> element: aName attributes: attributes with: content [
	self open: aName attributes: attributes.
	self write: content.
	stream nextPutAll: '</'; nextPutAll: aName; nextPut: $>
]

{ #category : 'writing' }
TwHtml >> element: aName with: content [
	self element: aName attributes: #() with: content
]

{ #category : 'private' }
TwHtml >> escape: aString [
	| escaped |
	escaped := WriteStream on: String new.
	aString do: [:each | | special |
		special := '&<>"''' indexOf: each.
		special = 0
			ifTrue: [escaped nextPut: each]
			ifFalse: [escaped nextPutAll: (#('&amp;' '&lt;' '&gt;' '&quot;' '&#39;') at: special)]].
	^ escaped contents
]

{ #category : 'elements' }
TwHtml >> form: content [
	self element: 'form' with: content
]

{ #category : 'elements' }
TwHtml >> form: attributes with: content [
	self element: 'form' attributes: attributes with: content
]

{ #category : 'elements' }
TwHtml >> h1: content [
	self element: 'h1' with: content
]

{ #category : 'elements' }
TwHtml >> h1: attributes with: content [
	self element: 'h1' attributes: attributes with: content
]

{ #category : 'elements' }
TwHtml >> h2: content [
	self element: 'h2' with: content
]

{ #category : 'elements' }
TwHtml >> h2: attributes with: content [
	self element: 'h2' attributes: attributes with: content
]

{ #category : 'elements' }
TwHtml >> h3: content [
	self element: 'h3' with: content
]

{ #category : 'elements' }
TwHtml >> h3: attributes with: content [
	self element: 'h3' attributes: attributes with: content
]

{ #category : 'private' }
TwHtml >> initialize [
	stream := WriteStream on: String new
]

{ #category : 'elements' }
TwHtml >> input: attributes [
	self void: 'input' attributes: attributes
]

{ #category : 'elements' }
TwHtml >> label: content [
	self element: 'label' with: content
]

{ #category : 'elements' }
TwHtml >> label: attributes with: content [
	self element: 'label' attributes: attributes with: content
]

{ #category : 'elements' }
TwHtml >> li: content [
	self element: 'li' with: content
]

{ #category : 'elements' }
TwHtml >> li: attributes with: content [
	self element: 'li' attributes: attributes with: content
]

{ #category : 'elements' }
TwHtml >> ol: content [
	self element: 'ol' with: content
]

{ #category : 'elements' }
TwHtml >> ol: attributes with: content [
	self element: 'ol' attributes: attributes with: content
]

{ #category : 'private' }
TwHtml >> open: aName attributes: attributes [
	stream nextPut: $<; nextPutAll: aName.
	attributes do: [:each |
		stream space; nextPutAll: (self attributeNamed: each key); nextPutAll: '="'; nextPutAll: (self escape: each value asString); nextPut: $"].
	stream nextPut: $>
]

{ #category : 'elements' }
TwHtml >> p: content [
	self element: 'p' with: content
]

{ #category : 'elements' }
TwHtml >> p: attributes with: content [
	self element: 'p' attributes: attributes with: content
]

{ #category : 'writing' }
TwHtml >> raw: aString [
	stream nextPutAll: aString
]

{ #category : 'writing' }
TwHtml >> render: aView [
	self div: {'tw-view' -> (aView id ifNil: [''])} with: [self raw: aView render]
]

{ #category : 'elements' }
TwHtml >> section: content [
	self element: 'section' with: content
]

{ #category : 'elements' }
TwHtml >> section: attributes with: content [
	self element: 'section' attributes: attributes with: content
]

{ #category : 'elements' }
TwHtml >> span: content [
	self element: 'span' with: content
]

{ #category : 'elements' }
TwHtml >> span: attributes with: content [
	self element: 'span' attributes: attributes with: content
]

{ #category : 'writing' }
TwHtml >> text: aString [
	stream nextPutAll: (self escape: aString)
]

{ #category : 'elements' }
TwHtml >> ul: content [
	self element: 'ul' with: content
]

{ #category : 'elements' }
TwHtml >> ul: attributes with: content [
	self element: 'ul' attributes: attributes with: content
]

{ #category : 'writing' }
TwHtml >> void: aName attributes: attributes [
	self open: aName attributes: attributes
]

{ #category : 'private' }
TwHtml >> write: content [
	content ifNil: [^ self].
	content isString ifTrue: [^ self text: content].
	content value
]
