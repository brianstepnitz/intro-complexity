## WHAT IS IT?

This model implements Huffman coding on a given input. It was completed as part of the coursework for the "Introduction to Complexity" class held by Complexity Explorer ( https://www.complexityexplorer.org/courses/119-introduction-to-complexity ) Unit 4 "Information, Order, and Randomness"

## HOW IT WORKS

Reads in the input, counts the frequency of every character, builds a binary tree of those frequencies, then uses that to make a Huffman encoding of the characters.

## HOW TO USE IT

* `Setup` - clears the output
* `Go` - runs the Huffman encoding on `input`
* `input` - the text to encode

## THINGS TO NOTICE

As implemented, the model treats capital letters as different than lower case, and includes all punctuation from the `input` in the encoding. Use all caps (or all lower case) and leave out all punctuation in the `input` to just see the encoding on just letters.

## THINGS TO TRY

Vary the input between more random distribution of characters and more repeated characters. Notice how the "bits per character" statistic changes.

## EXTENDING THE MODEL

Strip out punctuation. Treat capital and lower case letters the same. Show the frequency binary tree.

## CREDITS AND REFERENCES

The Hong Kong University of Science and Technology COMP271 Design and Analysis of Algorithms Spring 2003 Lecture 17 "Huffman Encoding" Notes: http://home.cse.ust.hk/faculty/golin/COMP271Sp03/Notes/MyL17.pdf

## COPYRIGHT AND LICENSE

### The MIT License (MIT)

Copyright 2021 Brian Stepnitz

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.