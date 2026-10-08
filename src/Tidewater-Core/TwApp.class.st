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
TwApp >> router [
	^ Router new
		get: '/' do: [:request :response | response content: view render];
		yourself
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
