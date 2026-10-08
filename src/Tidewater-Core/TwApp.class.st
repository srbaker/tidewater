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
TwApp >> handle: aRequest [
	^ self router handle: aRequest
]

{ #category : 'handling' }
TwApp >> router [
	^ Router new
		get: '/' do: [:request :response | response content: view render];
		yourself
]

{ #category : 'initialization' }
TwApp >> setView: aView [
	view := aView
]
