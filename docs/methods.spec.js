import { test, expect } from '@playwright/test';
import { mkdtempSync, mkdirSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { expandMethods, methodSource } from './.vitepress/methods.js';

const source = `Class {
	#name : 'Greeter',
	#superclass : 'Object',
	#category : 'Examples'
}

{ #category : 'instance creation' }
Greeter class >> on: aName [
	^ self new setName: aName
]

{ #category : 'greeting' }
Greeter >> greet [
	^ 'Hello'
]

{ #category : 'greeting' }
Greeter >> greet: aName with: aGreeting [
	| words |
	words := Array with: aGreeting with: aName.
	^ words inject: '' into: [:all :each | all, each]
]
`;

function project() {
  const root = mkdtempSync(join(tmpdir(), 'methods-'));
  mkdirSync(join(root, 'src', 'Examples'), { recursive: true });
  writeFileSync(join(root, 'src', 'Examples', 'Greeter.class.st'), source);
  return root;
}

test('shows a unary method as it reads in a browser', () => {
  expect(methodSource(project(), 'Greeter >> greet')).toBe("Greeter >> greet\n\t^ 'Hello'");
});

test('finds a keyword method by its selector, with its argument names', () => {
  expect(methodSource(project(), 'Greeter >> greet:with:')).toBe([
    'Greeter >> greet: aName with: aGreeting',
    '\t| words |',
    '\twords := Array with: aGreeting with: aName.',
    "\t^ words inject: '' into: [:all :each | all, each]",
  ].join('\n'));
});

test('finds a class-side method', () => {
  expect(methodSource(project(), 'Greeter class >> on:')).toBe('Greeter class >> on: aName\n\t^ self new setName: aName');
});

test('says which method it could not find', () => {
  expect(() => methodSource(project(), 'Greeter >> wave')).toThrow('No method Greeter >> wave');
});

test('turns a methods fence into the Smalltalk of the methods it names', () => {
  const tokens = [
    { type: 'fence', info: 'methods', content: 'Greeter >> greet\nGreeter class >> on:\n' },
    { type: 'fence', info: 'js', content: 'greet()\n' },
  ];
  expandMethods(tokens, project());
  expect(tokens[0]).toEqual({ type: 'fence', info: 'smalltalk', content: "Greeter >> greet\n\t^ 'Hello'\n\nGreeter class >> on: aName\n\t^ self new setName: aName\n" });
  expect(tokens[1]).toEqual({ type: 'fence', info: 'js', content: 'greet()\n' });
});
