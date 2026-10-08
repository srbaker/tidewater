Class {
	#name : 'TwApp',
	#superclass : 'Object',
	#instVars : [
		'view'
	],
	#category : 'Tidewater-Core'
}

{ #category : 'instance creation' }
TwApp class >> on: aView [
	^ self new setView: aView
]

{ #category : 'handling' }
TwApp >> renderInto: aResponse [
	aResponse content: view render
]

{ #category : 'handling' }
TwApp >> router [
	^ Router new
		get: '/' do: [:request :response | self renderInto: response];
		post: '/:action' do: [:request :response :action | self run: action asSymbol into: response];
		yourself
]

{ #category : 'handling' }
TwApp >> run: anAction into: aResponse [
	(view actions includes: anAction) ifFalse: [^ aResponse code: 404].
	view perform: anAction.
	self renderInto: aResponse
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
TwApp >> setView: aView [
	view := aView
]
