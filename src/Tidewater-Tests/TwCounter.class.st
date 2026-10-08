Class {
	#name : 'TwCounter',
	#superclass : 'Object',
	#instVars : [
		'count'
	],
	#category : 'Tidewater-Tests'
}

{ #category : 'instance creation' }
TwCounter class >> new [
	^ super new initialize
]

{ #category : 'accessing' }
TwCounter >> count [
	^ count
]

{ #category : 'counting' }
TwCounter >> increment [
	count := count + 1
]

{ #category : 'initialization' }
TwCounter >> initialize [
	self reset
]

{ #category : 'counting' }
TwCounter >> reset [
	count := 0
]
