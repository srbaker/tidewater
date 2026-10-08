Class {
	#name : 'TwTransactionTest',
	#superclass : 'TestCase',
	#category : 'Tidewater-Tests'
}

{ #category : 'tests' }
TwTransactionTest >> testAbortsRunsAndCommits [
	| system |
	system := TwMockSystem new.
	(TwTransaction on: system) do: [system log add: #action].
	self assert: system log asArray equals: #(#abortTransaction #action #commitTransaction)
]
