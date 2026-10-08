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
TwSessionTest >> testWatchesObjectsAndRefreshesWhenTheyChange [
	| system notifications |
	system := TwMockSystem new.
	notifications := TwMockNotifications new.
	(TwSession on: system notifying: notifications) watch: #(#a #b) then: [system log add: #changed].
	notifications signal.
	Processor yield.
	self assert: system watched equals: #(#a #b).
	self
		assert: system log asArray
		equals: #(#addAllToNotifySet: #enableSignaledObjectsError #signaledObjects #enableSignaledObjectsError #abortTransaction #changed)
]
