Class {
	#name : 'TwMockListener',
	#superclass : 'Object',
	#instVars : [
		'port',
		'router',
		'running'
	],
	#category : 'Tidewater-Tests'
}

{ #category : 'testing' }
TwMockListener >> isRunning [
	^ running = true
]

{ #category : 'accessing' }
TwMockListener >> port [
	^ port
]

{ #category : 'accessing' }
TwMockListener >> port: aPort [
	port := aPort
]

{ #category : 'accessing' }
TwMockListener >> router [
	^ router
]

{ #category : 'accessing' }
TwMockListener >> router: aRouter [
	router := aRouter
]

{ #category : 'running' }
TwMockListener >> run [
	running := true
]
