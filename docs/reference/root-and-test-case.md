# TwRoot and TwTestCase

## TwRoot

The superclass of an [aggregate root](../guide/watching#aggregate-roots): an object that owns others, and is watched in their place.

| Message | |
| --- | --- |
| `touch` | Marks the root changed. End every change to what it owns with it. |
| `version` | Answers how many times it's been touched. |

A subclass that implements `initialize` should send `super initialize`.

## TwTestCase

A `TestCase` with one more assertion. See [Testing](../guide/testing).

| Message | |
| --- | --- |
| `assertView: aView noticesChangesBy: aBlock` | Runs `aBlock`, and fails if it changed the view's render without changing anything the view watches. |
