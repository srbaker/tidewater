Class {
	#name : 'TwHtmlTest',
	#superclass : 'TestCase',
	#instVars : [
		'html'
	],
	#category : 'Tidewater-Tests'
}

{ #category : 'running' }
TwHtmlTest >> setUp [
	html := TwHtml new
]

{ #category : 'tests' }
TwHtmlTest >> testEscapesAttributeValues [
	html input: {#value -> ('"><', '''s')}.
	self assert: html contents equals: '<input value="&quot;&gt;&lt;&#39;s">'
]

{ #category : 'tests' }
TwHtmlTest >> testNestsWhatBlocksWrite [
	html ul: [html li: 'milk'. html li: 'eggs'].
	self assert: html contents equals: '<ul><li>milk</li><li>eggs</li></ul>'
]

{ #category : 'tests' }
TwHtmlTest >> testRefusesEventsItDoesNotKnow [
	self should: [html button: {#onClik -> #increment} with: '+'] raise: Error
]

{ #category : 'tests' }
TwHtmlTest >> testRendersChildViewsInsideTheirOwnView [
	| child |
	child := TwMockView rendering: '<p>child</p>'.
	child id: 'abc-1'.
	html render: child.
	self assert: html contents equals: '<div tw-view="abc-1"><p>child</p></div>'
]

{ #category : 'tests' }
TwHtmlTest >> testTakesAttributesBeforeContent [
	html button: {#onClick -> #increment} with: '+'.
	html form: {#onSubmit -> #add} with: [html button: 'Add'].
	self assert: html contents equals: '<button tw-click="increment">+</button><form tw-submit="add"><button>Add</button></form>'
]

{ #category : 'tests' }
TwHtmlTest >> testWiresInputToAnActionWithADebounce [
	html input: {#type -> 'search'. #name -> 'filter'. #value -> 'mi'. #onInput -> #filter. #debounce -> 200}.
	self assert: html contents equals: '<input type="search" name="filter" value="mi" tw-input="filter" tw-debounce="200">'
]

{ #category : 'tests' }
TwHtmlTest >> testWritesAnyOtherElementAndAttribute [
	html element: 'section' attributes: {'aria-label' -> 'Todos'} with: 'x'.
	html element: 'em' with: 'y'.
	self assert: html contents equals: '<section aria-label="Todos">x</section><em>y</em>'
]

{ #category : 'tests' }
TwHtmlTest >> testWritesElementsWithEscapedText [
	html p: 'Tom & <Jerry>'.
	self assert: html contents equals: '<p>Tom &amp; &lt;Jerry&gt;</p>'
]

{ #category : 'tests' }
TwHtmlTest >> testWritesRawHtmlOnlyWhenAskedTo [
	html text: '<b>'; raw: '<b>'.
	self assert: html contents equals: '&lt;b&gt;<b>'
]

{ #category : 'tests' }
TwHtmlTest >> testWritesVoidElementsFromTheirAttributes [
	html input: {#name -> 'item'. #hook -> #autofocus}.
	html button: 'Add'.
	self assert: html contents equals: '<input name="item" tw-hook="autofocus"><button>Add</button>'
]
