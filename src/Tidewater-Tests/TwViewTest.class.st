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
	view id: 'abc'; documentWith: #().
	counter increment.
	view push.
	warnings := WriteStream on: String new.
	view checkForUnwatchedChangesTo: warnings.
	self assert: warnings contents isEmpty
]

{ #category : 'tests' }
TwViewTest >> testEscapesTextForHtml [
	self
		assert: ((TwMockView rendering: '') escape: '<a href="x">Tom & Jerry''s</a>')
		equals: '&lt;a href=&quot;x&quot;&gt;Tom &amp; Jerry&#39;s&lt;/a&gt;'
]

{ #category : 'tests' }
TwViewTest >> testFindsItselfAndItsDescendantsById [
	| grandchild child parent |
	grandchild := TwMockView rendering: ''.
	child := TwMockView rendering: '' children: {grandchild}.
	parent := TwMockView rendering: '' children: {child}.
	parent id: 'abc'.
	parent render: child.
	child render: grandchild.
	self assert: (parent viewAt: 'abc') identical: parent.
	self assert: (parent viewAt: 'abc-1-1') identical: grandchild.
	self assert: (parent viewAt: 'abc-2') isNil
]

{ #category : 'tests' }
TwViewTest >> testKnowsWhereItsCodeLives [
	| code |
	code := (TwTodoView on: TwTodoList new) code.
	{TwTodoView. TwTodoForm. TwView} do: [:each |
		self assert: (code includesIdentical: (each persistentMethodDictForEnv: 0))].
	self deny: (code includesIdentical: (Object persistentMethodDictForEnv: 0))
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
TwViewTest >> testRemembersItsLastFiftyRenders [
	| counter view |
	counter := TwCounter new.
	view := TwCounterView on: counter.
	view id: 'abc'; documentWith: #().
	60 timesRepeat: [counter increment. view push].
	self assert: view history size equals: 50.
	self assert: view history first equals: '<p>11</p><button tw-click="increment">+</button>'.
	self assert: view history last equals: view render
]

{ #category : 'tests' }
TwViewTest >> testRendersAChildInsideItsOwnView [
	| child parent |
	child := TwMockView rendering: '<p>child</p>'.
	parent := TwMockView rendering: '' children: {child}.
	parent id: 'abc'.
	self assert: (parent render: child) equals: '<div tw-view="abc-1"><p>child</p></div>'.
	self assert: child id equals: 'abc-1'
]

{ #category : 'tests' }
TwViewTest >> testRendersADocumentCarryingItsId [
	| view |
	view := TwCounterView on: TwCounter new.
	view id: 'abc'.
	self
		assert: (view documentWith: #('morphdom.js' 'tidewater.js'))
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
TwViewTest >> testSendsItsCurrentRenderWhenAStreamOpens [
	| view socket |
	view := TwCounterView on: TwCounter new.
	socket := TwMockSocket whileOpen: [].
	view stream: socket.
	self assert: socket written asArray equals: {'retry: 1000', (String with: Character lf), (view eventFor: view render)}
]

{ #category : 'tests' }
TwViewTest >> testStopsAtAggregateRootsAndOtherViews [
	| list watches |
	list := TwTodoList new.
	list add: 'milk'.
	watches := (TwAutoView on: {list. TwAutoView on: 'child'}) watches.
	self assert: (watches includesIdentical: list).
	self deny: (watches includesIdentical: list items).
	self deny: (watches anySatisfy: [:each | each isKindOf: TwView])
]

{ #category : 'tests' }
TwViewTest >> testStopsStreamingWhenTheClientLeaves [
	| view socket |
	view := TwCounterView on: TwCounter new.
	socket := TwMockSocket whileOpen: [].
	view stream: socket.
	view push.
	self assert: socket written size equals: 1
]

{ #category : 'tests' }
TwViewTest >> testWarnsAboutChangesThatWereNeverPushed [
	| counter view warnings |
	counter := TwCounter new.
	view := TwCounterView on: counter.
	view id: 'abc'; documentWith: #().
	counter increment.
	warnings := WriteStream on: String new.
	view checkForUnwatchedChangesTo: warnings.
	self assert: (warnings contents includesString: 'TwCounterView changed without a watched object changing')
]

{ #category : 'tests' }
TwViewTest >> testWatchesWhatItReachesByDefault [
	| counter |
	counter := TwCounter new.
	self assert: ((TwAutoView on: counter) watches includesIdentical: counter)
]

{ #category : 'tests' }
TwViewTest >> testWatchesWhatItsChildrenWatch [
	| child parent |
	child := TwMockView watching: #(#b #c) children: #().
	parent := TwMockView watching: #(#a) children: {child}.
	self assert: parent allWatches asArray equals: #(#a #b #c)
]
