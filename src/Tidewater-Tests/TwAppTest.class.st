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
