Class {
	#name : 'TwMockStream',
	#superclass : 'WriteStream',
	#instVars : [
		'flushed'
	],
	#category : 'Tidewater-Tests'
}

{ #category : 'accessing' }
TwMockStream >> flush [
	flushed := true
]

{ #category : 'accessing' }
TwMockStream >> isFlushed [
	^ flushed = true
]
