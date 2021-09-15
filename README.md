# My "Introduction to Complexity" coursework

My homework for the Complexity Explorer "Introduction to Complexity" online course (<https://www.complexityexplorer.org/courses/119-introduction-to-complexity>).

For each unit, I worked on the "Advanced Level" option of the homework assignment.

## Contents

### Unit 1 - What is Complexity?

`MultipleAnts.nlogo` - Very simple model mostly just learning the extreme basics of the NetLogo modeling environment.

### Unit 2 - Dynamics and Chaos

`TurtlePellets.nlogo` - This one was actually a little bit interesting for me as a novice. It  A population of "turtles" roam their environment looking for food "pellets" that randomly show up. Various parameters for the turtles and environment can be set. When a turtle eats enough food, it produces a new turtle. Turtles may "die" of either old age, or not finding enough food. The result is an Agent-Based Model that seems to somewhat realistically show a Logistic Model of population birth/death rates

### Unit 3 - Fractals

`LSystems.nlogo` - In which I learn that NetLogo is not a great string processing environment. But the result is a very interesting fractal drawing program.

### Unit 4 - Information, Order, and Randomness

`HuffmanCoding.nlogo` - Basic Huffman coding implementation, where I learned to use the NetLogo `table` extension and dredged up memories from LISP of using lists to represent binary trees.

### Unit 6 - Cellular Automata

`EvolveCA.nlogo` - The most interesting assignment so far. I liked that it came directly from one of the instructors' own research. I spent a lot of time fiddling with this model, but finally had to admit that, as the instructor had warned, while NetLogo is a nice environment for prototyping and quickly understanding a model, it simply doesn't have the processing power for the sorts of high intensity calculations needed for this one. I did try harder to make my NetLogo code a bit more idiomatic, although I still haven't had a lot of exposure to much NetLogo code to compare to.

## Dependencies

* [NetLogo](https://ccl.northwestern.edu/netlogo/) modeling environment.

## Author

Brian Stepnitz - <brian.stepnitz@gmail.com>

## License

This project is licensed under the MIT License - see the `LICENSE` file for details