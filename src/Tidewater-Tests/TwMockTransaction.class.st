Class {
	#name : 'TwMockTransaction',
	#superclass : 'Object',
	#instVars : [
		'ran'
	],
	#category : 'Tidewater-Tests'
}

{ #category : 'running' }
TwMockTransaction >> do: aBlock [
	ran := true.
	^ aBlock value
]

{ #category : 'testing' }
TwMockTransaction >> hasRun [
	^ ran = true
]
