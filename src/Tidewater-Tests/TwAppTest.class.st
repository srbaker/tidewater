Class {
	#name : 'TwAppTest',
	#superclass : 'TestCase',
	#category : 'Tidewater-Tests'
}

{ #category : 'private' }
TwAppTest >> bodyOf: aResponse [
	| message |
	message := aResponse printString.
	^ message copyFrom: (message indexOfSubCollection: self crlf, self crlf) + 4 to: message size - 2
]

{ #category : 'private' }
TwAppTest >> crlf [
	^ String with: Character cr with: Character lf
]

{ #category : 'private' }
TwAppTest >> get: aPath [
	^ HttpRequest fromString: 'GET ', aPath, ' HTTP/1.1', self crlf, self crlf
]

{ #category : 'private' }
TwAppTest >> post: aPath [
	^ HttpRequest fromString: 'POST ', aPath, ' HTTP/1.1', self crlf, 'Content-Length: 0', self crlf, self crlf
]

{ #category : 'private' }
TwAppTest >> routerFor: aView [
	| listener |
	listener := TwMockListener new.
	(TwApp on: aView) serve: listener on: 8888.
	^ listener router
]

{ #category : 'tests' }
TwAppTest >> testPostingAnActionUpdatesTheView [
	| counter router |
	counter := TwCounter new.
	router := self routerFor: (TwCounterView on: counter).
	self assert: (self bodyOf: (router handle: (self post: '/increment'))) equals: '<p>1</p>'.
	self assert: counter count equals: 1
]

{ #category : 'tests' }
TwAppTest >> testPostingAnUnknownActionIsNotFound [
	| router |
	router := self routerFor: (TwCounterView on: TwCounter new).
	self assert: (router handle: (self post: '/render')) code equals: 404
]

{ #category : 'tests' }
TwAppTest >> testServesItsViewWithAListenerOnAPort [
	| app listener |
	app := TwApp on: (TwCounterView on: TwCounter new).
	listener := TwMockListener new.
	app serve: listener on: 8888.
	self assert: listener port equals: 8888.
	self assert: listener isRunning.
	self assert: (self bodyOf: (listener router handle: (self get: '/'))) equals: '<p>0</p>'
]
