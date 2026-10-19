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
TwSessionTest >> testGivesUpCleanlyWhenCommitsKeepConflicting [
	| system |
	system := TwMockSystem new.
	system failCommits: 1000.
	self should: [(TwSession on: system) do: [system log add: #action]] raise: TwConflict.
	self assert: system log last equals: #abortTransaction.
	self assert: (system log occurrencesOf: #action) equals: 10
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
TwSessionTest >> testReactsOnceToABurstOfChanges [
	| system session reactions |
	system := TwMockSystem new.
	session := TwSession on: system.
	reactions := 0.
	session whenChanged: [reactions := reactions + 1].
	[system commitChangeTo: #a; commitChangeTo: #b; commitChangeTo: #a.
	session poll; poll.
	self assert: reactions equals: 1]
		ensure: [session stop]
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

{ #category : 'tests' }
TwSessionTest >> testRefreshesOnlyBetweenActions [
	| system session |
	system := TwMockSystem new.
	session := TwSession on: system.
	session do: [
		system log add: #action.
		[session refresh] fork.
		(Delay forMilliseconds: 10) wait.
		system log add: #resumed].
	(Delay forMilliseconds: 10) wait.
	self
		assert: system log asArray
		equals: #(#abortTransaction #action #resumed #commitTransaction #abortTransaction)
]

{ #category : 'tests' }
TwSessionTest >> testRetriesWhenACommitConflicts [
	| system |
	system := TwMockSystem new.
	system failCommits: 2.
	(TwSession on: system) do: [system log add: #action].
	self
		assert: system log asArray
		equals: #(#abortTransaction #action #commitTransaction #abortTransaction #action #commitTransaction #abortTransaction #action #commitTransaction)
]

{ #category : 'tests' }
TwSessionTest >> testWaitsForAnActionInProgressBeforeRefreshing [
	"An abort is the whole gem's, so refreshing in the middle of an action would discard its work."

	| system session |
	system := TwMockSystem new.
	session := TwSession on: system.
	session whenChanged: [system log add: #changed].
	[session do: [
		system log add: #action.
		system commitChangeTo: #a.
		[session poll] fork.
		(Delay forMilliseconds: 10) wait.
		system log add: #resumed].
	(Delay forMilliseconds: 10) wait.
	self
		assert: (system log copyWithout: #signaledObjects) asArray
		equals: #(#abortTransaction #action #resumed #commitTransaction #abortTransaction #changed)]
		ensure: [session stop]
]

{ #category : 'tests' }
TwSessionTest >> testWatchesOnlyCommittedObjects [
	| system |
	system := TwMockSystem new.
	(TwSession on: system) watch: {#committed. Object new}.
	self assert: system watched asArray equals: #(#committed)
]
