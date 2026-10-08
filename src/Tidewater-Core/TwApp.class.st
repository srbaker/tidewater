Class {
	#name : 'TwApp',
	#superclass : 'Object',
	#instVars : [
		'view',
		'transaction'
	],
	#category : 'Tidewater-Core'
}

{ #category : 'instance creation' }
TwApp class >> on: aView [
	^ self on: aView in: (TwTransaction on: System)
]

{ #category : 'instance creation' }
TwApp class >> on: aView in: aTransaction [
	^ self new setView: aView transaction: aTransaction
]

{ #category : 'rendering' }
TwApp >> page [
	^ '<!DOCTYPE html><html><head><script src="/morphdom.js" defer></script><script src="/tidewater.js" defer></script></head><body><div tw-view>', view render, '</div></body></html>'
]

{ #category : 'handling' }
TwApp >> renderInto: aResponse [
	aResponse content: view render
]

{ #category : 'handling' }
TwApp >> router [
	^ Router new
		get: '/' do: [:request :response | response content: self page];
		get: '/:script' do: [:request :response :script | self script: script into: response];
		post: '/:action' do: [:request :response :action | self run: action asSymbol into: response];
		yourself
]

{ #category : 'handling' }
TwApp >> run: anAction into: aResponse [
	(view actions includes: anAction) ifFalse: [^ aResponse code: 404].
	transaction do: [view perform: anAction].
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
	aListener port: aPort; router: self router; run
]

{ #category : 'serving' }
TwApp >> serveOn: aPort [
	self serve: HttpListener new on: aPort
]

{ #category : 'initialization' }
TwApp >> setView: aView transaction: aTransaction [
	view := aView.
	transaction := aTransaction
]

{ #category : 'accessing' }
TwApp >> transaction [
	^ transaction
]
