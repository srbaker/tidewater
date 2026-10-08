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
TwSessionTest >> testDoesNothingWhenNothingWatchedHasChanged [
	| system session |
	system := TwMockSystem new.
	session := TwSession on: system.
	session whenChanged: [system log add: #changed].
	[session poll.
	self assert: system log asArray equals: #(#signaledObjects)]
		ensure: [session stop]
]

{ #category : 'tests' }
TwSessionTest >> testKeepsPollingWhileWatching [
	| session |
	session := TwSession on: TwMockSystem new.
	session whenChanged: [].
	[self assert: session isPolling] ensure: [session stop].
	self deny: session isPolling
]

{ #category : 'tests' }
TwSessionTest >> testRefreshesAndReactsWhenAWatchedObjectHasChanged [
	| system session |
	system := TwMockSystem new.
	session := TwSession on: system.
	session whenChanged: [system log add: #changed].
	[session watch: #(#a #b).
	system commitChangeTo: #a.
	session poll.
	self assert: system watched equals: #(#a #b).
	self assert: system log asArray equals: #(#addAllToNotifySet: #signaledObjects #abortTransaction #changed)]
		ensure: [session stop]
]
