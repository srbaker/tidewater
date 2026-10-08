Class {
	#name : 'TwMockListener',
	#superclass : 'Object',
	#instVars : [
		'port',
		'router',
		'running',
		'listenBacklog'
	],
	#category : 'Tidewater-Tests'
}

{ #category : 'testing' }
TwMockListener >> isRunning [
	^ running = true
]

{ #category : 'accessing' }
TwMockListener >> listenBacklog [
	^ listenBacklog
]

{ #category : 'accessing' }
TwMockListener >> listenBacklog: anInteger [
	listenBacklog := anInteger
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
