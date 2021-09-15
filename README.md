# My "Introduction to Complexity" coursework

My homework for the Complexity Explorer "Introduction to Complexity" online course (<https://www.complexityexplorer.org/courses/119-introduction-to-complexity>).

For each unit, I worked on the "Advanced Level" option of the homework assignment.

## Contents

### Unit 1 - What is Complexity?

`MultipleAnts.nlogo` - Very simple model mostly just learning the extreme basics of the NetLogo modeling environment.

### Unit 2 - Dynamics and Chaos

`TurtlePellets.nlogo` - This one was actually a little bit interesting for me as a novice. It  A population of "turtles" roam their environment looking for food "pellets" that randomly show up. Various parameters for the turtles and environment can be set. When a turtle eats enough food, it produces a new turtle. Turtles may "die" of either old age, or not finding enough food. The result is an Agent-Based Model that seems to somewhat realistically almost show a [Logistic map](https://en.wikipedia.org/wiki/Logistic_map) of population birth/death rates

### Unit 3 - Fractals

`LSystems.nlogo` - In which I learn that NetLogo is not a great string processing environment. But the result is a very interesting fractal drawing program.

### Unit 4 - Information, Order, and Randomness

`HuffmanCoding.nlogo` - Basic Huffman coding implementation, where I learned to use the NetLogo `table` extension and dredged up memories from LISP of using lists to represent binary trees.

### Unit 6 - Cellular Automata

`EvolveCA.nlogo` - The most interesting assignment so far. I liked that it came directly from one of the instructors' own research. I spent a lot of time fiddling with this model, but finally had to admit that, as the instructor had warned, while NetLogo is a nice environment for prototyping and quickly understanding a model, it simply doesn't have the processing power for the sorts of high intensity calculations needed for this one. I did try harder to make my NetLogo code a bit more idiomatic, although I still haven't had a lot of exposure to much NetLogo code to compare to.

#### Gnomes in Hats

In trying to explain this assignment to my family, I reached for a common setup in mathematical puzzles of Gnomes in Hats (representative example [here](https://www.intelliot.com/2004/09/gnomes-puzzle/) although there are many varieties). So for this assignment, my setup was: you have an odd number of gnomes in a circle where each gnome wears a White hat or a Black hat. Each gnome can only see its own hat and the hats of the two gnomes to their left and two gnomes to their right and otherwise cannot see any other gnomes nor can they communicate with any gnomes. At each timestep, each gnome can look at the hats they can see, and then all gnomes simultaneously and instantaneously decide to either keep their hat or put on the other color of hat. The goal is for every gnome in the circle to end up wearing the same color of hat that the majority of ALL gnomes in the cirlce were wearing at the very first timestep. Is there a uniform set of rules that every gnome can independently follow to achieve that result?

I thought of each gnome having a "codebook" that every gnome shared and that they could refer to when deciding whether to change hats. "Okay, for me and the four other gnomes I can see, we are in pattern WWBWW. Looking up that pattern, the codebook says I should change my hat to White. Got it.". Now, there are stupendously many possible such codebooks, so the assignment is to use a Genetic Algorithm to try to find a codebook gives the gnomes the strategy to succeed.

Outside of VERY small gnome circles (only 5 or 7 or so gnomes), my program never succeeded in finding a perfect strategy. It would get CLOSE, with solutions that gave the right answer some very high (nearly 100%) proportion of the time. But never perfect. I definitely felt the computational speed limits of the NetLogo modeling environment for this one.

(Also, as an interesting aside, in early iterations of my model, I only checked if all of the gnomes had the proper colored hat in the FINAL timestep. An interesting strategy that evolved was for all of the gnomes to converge on SOME color, regardless of majority or not, and then "blink" back and forth between the colors, hoping that the simulation ended with the right color showing. When I saw that happen over and over again, I changed the fitness criteria to measure the final TWO timesteps instead.)

## Dependencies

* [NetLogo](https://ccl.northwestern.edu/netlogo/) modeling environment.

## Author

Brian Stepnitz - <brian.stepnitz@gmail.com>

## License

This project is licensed under the MIT License - see the `LICENSE` file for details