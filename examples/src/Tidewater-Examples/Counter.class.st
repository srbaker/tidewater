Class {
	#name : 'Counter',
	#superclass : 'Object',
	#instVars : [
		'count'
	],
	#category : 'Tidewater-Examples'
}

{ #category : 'instance creation' }
Counter class >> new [
	^ super new initialize
]

{ #category : 'accessing' }
Counter >> count [
	^ count
]

{ #category : 'counting' }
Counter >> increment [
	count := count + 1
]

{ #category : 'initialization' }
Counter >> initialize [
	self reset
]

{ #category : 'counting' }
Counter >> reset [
	count := 0
]
