Class {
	#name : 'TwRoot',
	#superclass : 'Object',
	#instVars : [
		'version'
	],
	#category : 'Tidewater-Core'
}

{ #category : 'instance creation' }
TwRoot class >> new [
	^ super new initialize
]

{ #category : 'initialization' }
TwRoot >> initialize [
	version := 0
]

{ #category : 'changing' }
TwRoot >> touch [
	version := version + 1
]

{ #category : 'accessing' }
TwRoot >> version [
	^ version
]
