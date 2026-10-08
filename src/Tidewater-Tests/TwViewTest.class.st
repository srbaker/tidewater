Class {
	#name : 'TwViewTest',
	#superclass : 'TestCase',
	#category : 'Tidewater-Tests'
}

{ #category : 'tests' }
TwViewTest >> testDoesNotWarnAboutPushedChanges [
	| counter view warnings |
	counter := TwCounter new.
	view := TwCounterView on: counter.
	view id: 'abc'; document.
	counter increment.
	view push.
	warnings := WriteStream on: String new.
	view checkForUnwatchedChangesTo: warnings.
	self assert: warnings contents isEmpty
]

{ #category : 'tests' }
TwViewTest >> testPrefixesEveryLineOfAnEvent [
	| lf |
	lf := String with: Character lf.
	self
		assert: ((TwMockView rendering: '') eventFor: '<p>', lf, 'one', lf, '</p>')
		equals: 'data: <p>', lf, 'data: one', lf, 'data: </p>', lf, lf
]

{ #category : 'tests' }
TwViewTest >> testPushesItselfToItsStreams [
	| counter view socket |
	counter := TwCounter new.
	view := TwCounterView on: counter.
	socket := TwMockSocket whileOpen: [counter increment. view push].
	view stream: socket.
	self assert: socket written last equals: (view eventFor: '<p>1</p><button tw-click="increment">+</button>')
]

{ #category : 'tests' }
TwViewTest >> testRendersADocumentCarryingItsId [
	| view |
	view := TwCounterView on: TwCounter new.
	view id: 'abc'.
	self
		assert: view document
		equals: '<!DOCTYPE html><html><head><script src="/morphdom.js" defer></script><script src="/tidewater.js" defer></script></head><body><div tw-view="abc">', view render, '</div></body></html>'
]

{ #category : 'tests' }
TwViewTest >> testRendersTheCountAndAnIncrementButton [
	| counter |
	counter := TwCounter new.
	counter increment.
	self assert: (TwCounterView on: counter) render equals: '<p>1</p><button tw-click="increment">+</button>'
]

{ #category : 'tests' }
TwViewTest >> testResetsTheCounter [
	| counter |
	counter := TwCounter new.
	counter increment.
	counter reset.
	self assert: counter count equals: 0
]

{ #category : 'tests' }
TwViewTest >> testStopsStreamingWhenTheClientLeaves [
	| view socket |
	view := TwCounterView on: TwCounter new.
	socket := TwMockSocket whileOpen: [].
	view stream: socket.
	view push.
	self assert: socket written isEmpty
]

{ #category : 'tests' }
TwViewTest >> testWarnsAboutChangesThatWereNeverPushed [
	| counter view warnings |
	counter := TwCounter new.
	view := TwCounterView on: counter.
	view id: 'abc'; document.
	counter increment.
	warnings := WriteStream on: String new.
	view checkForUnwatchedChangesTo: warnings.
	self assert: (warnings contents includesString: 'TwCounterView changed without a watched object changing')
]
