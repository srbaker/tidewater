Class {
	#name : 'TwTodoList',
	#superclass : 'TwRoot',
	#instVars : [
		'items'
	],
	#category : 'Tidewater-Examples'
}

{ #category : 'adding' }
TwTodoList >> add: aString [
	items add: aString.
	self touch
]

{ #category : 'removing' }
TwTodoList >> clear [
	items := OrderedCollection new.
	self touch
]

{ #category : 'initialization' }
TwTodoList >> initialize [
	super initialize.
	items := OrderedCollection new
]

{ #category : 'accessing' }
TwTodoList >> items [
	^ items
]
