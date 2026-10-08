Class {
	#name : 'TwSessionTest',
	#superclass : 'TestCase',
	#category : 'Tidewater-Tests'
}

{ #category : 'tests' }
TwSessionTest >> testAbortsRunsAndCommits [
	| system |
	system := TwMockSystem new.
	(TwSession on: system) do: [system log add: #action].
	self assert: system log asArray equals: #(#abortTransaction #action #commitTransaction)
]

{ #category : 'tests' }
TwSessionTest >> testKeepsTheGemAwakeWhileWatching [
	| session |
	session := TwSession on: TwMockSystem new notifying: TwMockNotifications new.
	session whenChanged: [].
	[self assert: session isAwake] ensure: [session stop].
	self deny: session isAwake
]

{ #category : 'tests' }
TwSessionTest >> testWatchesObjectsAndRefreshesWhenTheyChange [
	| system notifications session |
	system := TwMockSystem new.
	notifications := TwMockNotifications new.
	session := TwSession on: system notifying: notifications.
	session whenChanged: [system log add: #changed].
	[session watch: #(#a #b).
	notifications signal.
	Processor yield.
	self assert: system watched equals: #(#a #b).
	self
		assert: system log asArray
		equals: #(#addAllToNotifySet: #enableSignaledObjectsError #signaledObjects #enableSignaledObjectsError #abortTransaction #changed)]
		ensure: [session stop]
]
