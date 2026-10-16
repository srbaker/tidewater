Class {
	#name : 'TodoList',
	#superclass : 'TwRoot',
	#instVars : [
		'items'
	],
	#category : 'Tidewater-Examples'
}

{ #category : 'adding' }
TodoList >> add: aString [
	items add: aString.
	self touch
]

{ #category : 'removing' }
TodoList >> clear [
	items := OrderedCollection new.
	self touch
]

{ #category : 'initialization' }
TodoList >> initialize [
	super initialize.
	items := OrderedCollection new
]

{ #category : 'accessing' }
TodoList >> items [
	^ items
]
