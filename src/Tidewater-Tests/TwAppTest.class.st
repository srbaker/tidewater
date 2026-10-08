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
	^ self routerFor: aView in: TwMockTransaction new
]

{ #category : 'private' }
TwAppTest >> routerFor: aView in: aTransaction [
	| listener |
	listener := TwMockListener new.
	(TwApp on: aView in: aTransaction) serve: listener on: 8888.
	^ listener router
]

{ #category : 'tests' }
TwAppTest >> testPostingAnActionUpdatesTheView [
	| counter view |
	counter := TwCounter new.
	view := TwCounterView on: counter.
	self assert: (self bodyOf: ((self routerFor: view) handle: (self post: '/increment'))) equals: view render.
	self assert: counter count equals: 1
]

{ #category : 'tests' }
TwAppTest >> testPostingAnUnknownActionIsNotFound [
	| router |
	router := self routerFor: (TwCounterView on: TwCounter new).
	self assert: (router handle: (self post: '/render')) code equals: 404
]

{ #category : 'tests' }
TwAppTest >> testRunsActionsInARealTransactionByDefault [
	| app |
	app := TwApp on: (TwCounterView on: TwCounter new).
	self assert: app transaction system identical: System
]

{ #category : 'tests' }
TwAppTest >> testRunsActionsInATransaction [
	| transaction |
	transaction := TwMockTransaction new.
	(self routerFor: (TwCounterView on: TwCounter new) in: transaction) handle: (self post: '/increment').
	self assert: transaction hasRun
]

{ #category : 'tests' }
TwAppTest >> testServesItsScripts [
	| router |
	router := self routerFor: (TwCounterView on: TwCounter new).
	self assert: ((self bodyOf: (router handle: (self get: '/tidewater.js'))) beginsWith: 'document.addEventListener').
	self assert: ((self bodyOf: (router handle: (self get: '/morphdom.js'))) beginsWith: '/*! morphdom')
]

{ #category : 'tests' }
TwAppTest >> testServesItsViewInAPage [
	| view |
	view := TwCounterView on: TwCounter new.
	self
		assert: (self bodyOf: ((self routerFor: view) handle: (self get: '/')))
		equals: '<!DOCTYPE html><html><head><script src="/morphdom.js" defer></script><script src="/tidewater.js" defer></script></head><body><div tw-view>', view render, '</div></body></html>'
]

{ #category : 'tests' }
TwAppTest >> testServesItsViewWithAListenerOnAPort [
	| view listener |
	view := TwCounterView on: TwCounter new.
	listener := TwMockListener new.
	(TwApp on: view) serve: listener on: 8888.
	self assert: listener port equals: 8888.
	self assert: listener isRunning.
	self assert: ((self bodyOf: (listener router handle: (self get: '/'))) includesString: view render)
]

{ #category : 'tests' }
TwAppTest >> testServesNoOtherFiles [
	| router |
	router := self routerFor: (TwCounterView on: TwCounter new).
	self assert: (router handle: (self get: '/tidewater.spec.js')) code equals: 404.
	self assert: (router handle: (self get: '/../package.json')) code equals: 404
]
