Class {
	#name : 'TwTestCaseTest',
	#superclass : 'TestCase',
	#category : 'Tidewater-Tests'
}

{ #category : 'tests' }
TwTestCaseTest >> testFailsWhenTheRenderChangesButNothingWatchedDoes [
	| html |
	html := 'before' copy.
	self
		should: [TwTestCase new assertView: (TwMockView rendering: html) noticesChangesBy: [html replaceFrom: 1 to: 6 with: 'after!']]
		raise: TestFailure
]

{ #category : 'tests' }
TwTestCaseTest >> testPassesWhenAWatchedObjectChanges [
	| counter |
	counter := TwCounter new.
	TwTestCase new assertView: (TwCounterView on: counter) noticesChangesBy: [counter increment]
]
