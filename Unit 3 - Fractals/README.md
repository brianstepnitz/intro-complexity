## WHAT IS IT?

This model implements a method to draw Lindenmayer Systems from a given axiom and ruleset. It was completed as part of the coursework for the "Introduction to Complexity" class held by Complexity Explorer ( https://www.complexityexplorer.org/courses/119-introduction-to-complexity ) Unit 3 "Fractals"

## HOW IT WORKS

It reads the axiom and the ruleset from the input fields. The cursor begins in the middle of the world space. At each timestep, the cursor draws according to the instructions in the current state, starting with the axiom at the first timestep. Then the state transforms according to the rules as a string-rewriting system.

The cursor draws as follows:

* `f` or `h` - draw a straight line of step-size length
* `g`- move the cursor in a straight line of step-size length without drawing a line
* `+` or `-` - turn left or right, respectively, in turn-angle increment
* `[` - save the current position and heading of the cursor on a stack
* `]` - pop the last saved position and heading and return the cursor to it without drawing

Any other symbols are ignored by the drawing program, but may be used in the string-rewriting rules.

## HOW TO USE IT

Enter the starting state into the `Axiom` input field.

Enter the rules into the "Rules" input field as a list-of-strings: the first item is the first predecesssor, the second item is the successor of the first predecessor, the third item is the second predecessor, the fourth item is the successor of the second predecessor, etc. For example, ["f", "f-g+f+g-f", "g" "gg"] is equivalent to the rules:

> f → f-g+f+g-f
> g → gg

`step-size` sets how far the cursor moves at each step
`initial-heading` sets the initial heading that the cursor will move in
`angle-increment` sets the angle that the cursor will turn right or left

Enter the input parameters and then press the `Setup` button. Press the `Step` button to see a single step of the L-System, or press the `Go🔁` button to continuously step through the system.

## THINGS TO TRY

### Sierpinski Triangle
> **Axiom:** f-g-g
>
> **Rules:**
>
> f → f-g+f+g-f
> g → gg
>
> **Angle Increment:** 120°

### Dragon Curve
> **Axiom:** f
>
> **Rules:**
>
> f → f+g
> g → f-g
>
> **Angle Increment:** 90°

### Fractal Plant
> **Axiom:** X
> **Rules:**
>
> X → f+[[X]-X]-f[-fX]+X
> f → ff
>
> **Angle Increment:**  25°

Note how the variable "X" is used in the string-rewriting rules for the Fractal Plant.

## NETLOGO FEATURES

Reading the input strings to define the rules was tricky. NetLogo seems to provide only the most bare-bones of string processing capabilities. Hence why the rules need to be provided in the list-of-strings format described above.

With a little more effort, one could probably achieve a better handling of the input strings but that went beyond the scope of this assignment.

## RELATED MODELS

As specified in the assignment, the NetLogo "L-System Fractals" model was **NOT** used in developing this model.

## CREDITS AND REFERENCES

The University of New Mexico - Joel Castellanos - Lindenmayer Systems: Details -  http://www.cs.unm.edu/~joel/PaperFoldingFractal/L-system-rules.html

## COPYRIGHT AND LICENSE

### The MIT License (MIT)

Copyright 2021 Brian Stepnitz

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.