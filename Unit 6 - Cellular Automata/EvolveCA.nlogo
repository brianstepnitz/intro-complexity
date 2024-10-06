extensions [table]

globals [
  the-lineup
  the-iteration
  the-initial-majority
]

breed [codebooks codebook]

codebooks-own [
  my-code-boollist
  my-fitness
]

to setup
  clear-output
  clear-turtles
  clear-all-plots

  resize-world 0 (lineup-width - 1) (1 - mean-iterations) 0

  set-current-plot "Fitness"
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Running and displaying a single rule
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to populate-lineup
  clear-patches

  ifelse (randomly-populate?) [
    set the-lineup (random-boollist lineup-width lineup-density)
    set lineup-id (to-hexstring the-lineup)
  ] [
    set the-lineup (from-hexstring lineup-id lineup-width)
  ]

  set the-iteration 0
  draw-lineup the-lineup
  set the-initial-majority calc-majority-state the-lineup
end

to draw-lineup [lineup]
  let index 0
  while [index < length the-lineup] [
    if (item index the-lineup) [
      ask patch index (- the-iteration) [set pcolor white]
    ]
    set index (index + 1)
  ]
end

to run-codebook-once [code-boollist]
  set the-iteration (the-iteration + 1)
  set the-lineup (calc-next-lineup code-boollist the-lineup)

  draw-lineup the-lineup
end

to run-codebook
  let code-boollist ( from-hexstring codebook-id (2 ^ (2 * sight-range + 1)) )

  while [the-iteration < mean-iterations - 1] [
    run-codebook-once code-boollist
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Run the genetic algorithm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to go

  ; make initial codebooks
  create-codebooks num-codebooks [
    set hidden? true
    set my-code-boollist (random-boollist (2 ^ (2 * sight-range + 1)) (random-float 1))
    set my-fitness 0
  ]

  let perfects-count table:make
  let min-plotfitness-so-far []
  let max-plotfitness-so-far []

  foreach (range num-generations) [gen ->
    output-print (word "generation: " gen)
    reset-timer

    let lineups []
    foreach (range (1 + trial-increments)) [trial ->
      let proportion (trial / trial-increments)
      let lineup (random-boollist lineup-width proportion)
      set lineups (lput lineup lineups)
    ]

    ask codebooks [
      set my-fitness (run-trials my-code-boollist lineups)
    ]

    output-print (word timer " seconds to calculate fitnesses")

    let max-fitness [my-fitness] of (max-one-of codebooks [my-fitness])
    set min-plotfitness-so-far (ifelse-value (is-list? min-plotfitness-so-far or max-fitness < min-plotfitness-so-far) [max-fitness] [min-plotfitness-so-far])
    set max-plotfitness-so-far (ifelse-value (is-list? max-plotfitness-so-far or max-fitness > max-plotfitness-so-far) [max-fitness] [max-plotfitness-so-far])
    output-print (word "population max-fitness: " max-fitness)

    ask codebooks with-max [my-fitness] [
      output-print (word "* codebook-id: " (to-hexstring my-code-boollist))
      if (my-fitness = 1) [
        let my-codelist-id (to-hexstring my-code-boollist)
        let counts table:get-or-default perfects-count my-codelist-id 0
        table:put perfects-count my-codelist-id (counts + 1)
      ]
    ]

    let mean-fitness (mean [my-fitness] of codebooks)
    set min-plotfitness-so-far (ifelse-value (is-list? min-plotfitness-so-far or mean-fitness < min-plotfitness-so-far) [mean-fitness] [min-plotfitness-so-far])
    set max-plotfitness-so-far (ifelse-value (is-list? max-plotfitness-so-far or mean-fitness > max-plotfitness-so-far) [mean-fitness] [max-plotfitness-so-far])
    output-print (word "population mean-fitness: " mean-fitness)

    ; survival of the fittest
    let num-elite max ( list (selection * num-codebooks) (count codebooks with [my-fitness = 1]) )
    let num-bottom max ( list (num-codebooks - num-elite) 0 )
    ask min-n-of num-bottom (codebooks with [my-fitness > 0]) [my-fitness] [
      die
    ]

    let mean-elite-fitness (mean [my-fitness] of codebooks)
    set min-plotfitness-so-far (ifelse-value (is-list? min-plotfitness-so-far or mean-elite-fitness < min-plotfitness-so-far) [mean-elite-fitness] [min-plotfitness-so-far])
    set max-plotfitness-so-far (ifelse-value (is-list? max-plotfitness-so-far or mean-elite-fitness > max-plotfitness-so-far) [mean-elite-fitness] [max-plotfitness-so-far])
    output-print (word "elite mean-fitness: " mean-elite-fitness)

    set-plot-x-range -0.5 (gen + 0.5)
    set-plot-y-range ((precision (min-plotfitness-so-far - 0.01) 2)) ((precision (max-plotfitness-so-far + 0.01) 2))
    set-current-plot-pen "population max"
    plotxy gen max-fitness
    set-current-plot-pen "population mean"
    plotxy gen mean-fitness
    set-current-plot-pen "elite mean"
    plotxy gen mean-elite-fitness

    make-next-generation (turtle-set codebooks)
  ] ; next generation

  foreach sort-by [[pair1 pair2] -> (last pair1 < last pair2)] (table:to-list perfects-count) [pair -> output-print (word "codebook-id: " (first pair) " perfect-count: " (last pair))]
end

to make-next-generation [elite-codebooks]
  let total-fitness (sum [my-fitness] of elite-codebooks)
  create-codebooks (num-codebooks - (count elite-codebooks)) [
    set hidden? true

    let parent1 []
    let parent2 []

    let parents [self] of ( n-of 2 elite-codebooks )
    set parent1 (first parents)
    set parent2 (last parents)

    let boollist1 ([my-code-boollist] of parent1)
    let boollist2 ([my-code-boollist] of parent2)

    let crossover-index (random length boollist1)

    let cross1 (sublist boollist1 0 (crossover-index + 1))
    let cross2 ifelse-value (crossover-index < 1 + length boollist2) [sublist boollist2 (crossover-index + 1) (length boollist2)] [ [] ]
    let next-boollist (sentence cross1 cross2)

    set my-code-boollist (mutate-with-count mutation-count next-boollist)
    set my-fitness 0
  ]
end

to-report run-trials [code-boollist lineups]
  let total 0
  foreach (lineups) [lineup ->
    set total ( total + (run-iterations code-boollist lineup) )
  ]

  let mean-fitness (total / (1 + trial-increments))
  report mean-fitness
end

; run 'boollist' on 'start-lineup' for some number of iterations, report fitness
to-report run-iterations [code-boollist start-lineup]
  let iter 0
  let prev-lineup []
  let curr-lineup start-lineup

  let iteration-limit (random-poisson mean-iterations)
  ; if (fixed-iterations?) [ set iteration-limit mean-iterations ]

  while [iter < iteration-limit] [
    set prev-lineup curr-lineup
    let next-lineup (calc-next-lineup code-boollist curr-lineup)
    ifelse (next-lineup = curr-lineup) [
      set iter iteration-limit
    ]
    [
      set curr-lineup next-lineup
      set iter (iter + 1)
    ]
  ]

  ; report (calc-proportion-fitness majority-state prev-lineup curr-lineup)
  report (calc-performance-fitness (calc-majority-state start-lineup) curr-lineup)
end

to-report calc-majority-state [boollist]
  let num-true (reduce [ [true-so-far next-item] -> true-so-far + (ifelse-value next-item [1] [0]) ] (fput 0 boollist))
  let majority-state (num-true > lineup-width / 2)

  report majority-state
end

to-report mutate-with-count [num boollist]
  let indices (n-of num (range length boollist))
  foreach indices [index -> set boollist (replace-item index boollist (not item index boollist)) ]

  report boollist
end

; compute the proprotion of cells in 'prev-lineup' + 'end-lineup' that are in state 'majority-state'
to-report calc-proportion-fitness [majority-state prev-lineup end-lineup]
  let count-state (reduce [[count-so-far curr-state] -> ifelse-value (majority-state = curr-state) [count-so-far + 1] [count-so-far]] (fput 0 (sentence prev-lineup end-lineup)))

  report count-state / (2 * lineup-width)
end

to-report calc-performance-fitness [majority-state end-lineup]
  report ifelse-value (end-lineup = (n-values lineup-width [majority-state])) [1] [0]
end

to-report calc-next-lineup [code-boollist prev-lineup]
  let half-neighborhood (floor ((2 * sight-range + 1) / 2) )

  ; wrap the lineup around
  let tail (sublist prev-lineup (lineup-width - half-neighborhood) lineup-width)
  let head (sublist prev-lineup 0 half-neighborhood)
  ; it's an ouroboros
  let ring (sentence tail prev-lineup head)

  report last reduce [[neighborhood-lineup-so-far curr-elem] -> calc-next-elem code-boollist (first neighborhood-lineup-so-far) (last neighborhood-lineup-so-far) curr-elem] (fput (list [] []) ring)
end

to-report calc-next-elem [code-boollist prev-neighborhood next-lineup-so-far curr-elem]
  if (length prev-neighborhood < (2 * sight-range + 1) - 1) [
    ; still building up to first neighborhood
    report (list (lput curr-elem prev-neighborhood) next-lineup-so-far)
  ]

  let neighborhood (ifelse-value (length prev-neighborhood = (2 * sight-range + 1)) [lput curr-elem (but-first prev-neighborhood)] [lput curr-elem prev-neighborhood])

  let next-elem (eval-rule code-boollist neighborhood)

  report (list neighborhood (lput next-elem next-lineup-so-far))
end

; For a one-dimensional cellular automaton with neighborhood size 'n'
; There are 2^n corresponding possible neighborhood configurations
; So there are 2^(2^n) possible rules
; A code-boollist is a 2^(2^n) length binary array specifying one of those rules
; The code-boollist encodes the next cell state given
; every possible of its neighborhood configuration of the previous state
;
; This function starts with the entire code-boollist binary array
; and the entire neighborhood binary array
;
; If the first element in the neighborhood is 1,
; then the state of the cell is given in the first half of the code-boollist
; else the state is given in the last half of the code-boollist
;
; It then slices the code-boollist to that half,
; and slices off the first element of the neighborhood,
; and recurses down
; until the code-boollist-slice is a single element,
; which we know will be the next state of the cell
to-report eval-rule [code-boollist-slice neighborhood-slice]
  let l length code-boollist-slice
  report ifelse-value (l = 1)
  [
        last code-boollist-slice
  ]
  [
    ifelse-value first neighborhood-slice
    [
      eval-rule (sublist code-boollist-slice 0 (l / 2)) (but-first neighborhood-slice)
    ]
    [
      eval-rule (sublist code-boollist-slice (l / 2) l) (but-first neighborhood-slice)
    ]
  ]
end

to-report random-boollist [len proportion]
  let indices (n-of (round (len * proportion)) (n-values len [i -> i]))
  report n-values len [i -> member? i indices]
end

; encode 'num' as an 'arity'-bit boolean list
to-report to-arity-boollist [arity num]
  report pad-to-length (2 ^ arity) (to-boollist num)
end

; convert 'num' to a boollist
to-report to-boollist [num]
  report ifelse-value (num < 1)
  [
    []
  ]
  [
    lput (num mod 2 = 1) (to-boollist (floor (num / 2)))
  ]
end

; pad 'boollist' to a one of length 'len'
to-report pad-to-length [len boollist]
  if (length boollist > len) [
    error "list too long!"
  ]

  report ifelse-value (length boollist >= len) [
    boollist
  ]
  [
    pad-to-length len (fput false boollist)
  ]
end

; convert boollist to a number
to-report to-num [boollist]
  report ifelse-value (empty? boollist) [
    0
  ]
  [
    (2 ^ (length boollist - 1) * (ifelse-value (first boollist) [1] [0]))
    + (to-num but-first boollist)
  ]
end

; convert boollist to a hexadecimal string
to-report to-hexstring [boollist]
  let nibbles ( ceiling ((length boollist) / 4) )
  let the-boollist (pad-to-length (4 * nibbles) boollist)

  let index 0
  let hexstring ""
  while [index < length the-boollist] [
    let digit ( to-num sublist the-boollist index (index + 4) )
    (ifelse
      digit = 10 [ set hexstring (word hexstring "A") ]
      digit = 11 [ set hexstring (word hexstring "B") ]
      digit = 12 [ set hexstring (word hexstring "C") ]
      digit = 13 [ set hexstring (word hexstring "D") ]
      digit = 14 [ set hexstring (word hexstring "E") ]
      digit = 15 [ set hexstring (word hexstring "F") ]
      [ set hexstring (word hexstring digit) ]
    )
    set index (index + 4)
  ]

  report hexstring
end

; convert hexstring to a arity-length boollist
to-report from-hexstring [hexstring arity]
  let index 0
  let boollist []
  while [index < length hexstring] [
    let hexdigit ( item index hexstring )
    let boollist-digit []
    (ifelse
      hexdigit = "0" [ set boollist (sentence boollist false false false false) ]
      hexdigit = "1" [ set boollist (sentence boollist false false false true) ]
      hexdigit = "2" [ set boollist (sentence boollist false false true false) ]
      hexdigit = "3" [ set boollist (sentence boollist false false true true) ]
      hexdigit = "4" [ set boollist (sentence boollist false true false false) ]
      hexdigit = "5" [ set boollist (sentence boollist false true false true) ]
      hexdigit = "6" [ set boollist (sentence boollist false true true false) ]
      hexdigit = "7" [ set boollist (sentence boollist false true true true) ]
      hexdigit = "8" [ set boollist (sentence boollist true false false false) ]
      hexdigit = "9" [ set boollist (sentence boollist true false false true) ]
      hexdigit = "A" [ set boollist (sentence boollist true false true false) ]
      hexdigit = "B" [ set boollist (sentence boollist true false true true) ]
      hexdigit = "C" [ set boollist (sentence boollist true true false false) ]
      hexdigit = "D" [ set boollist (sentence boollist true true false true) ]
      hexdigit = "E" [ set boollist (sentence boollist true true true false) ]
      hexdigit = "F" [ set boollist (sentence boollist true true true true) ]
      [ print (word "ERROR! '" hexdigit "' is not a hexadecimal digit!") ]
    )

    set index ( index + 1 )
  ]

  while [length boollist > arity] [
    if (first boollist) [ print "ERROR! Removing `true` from a boollist" ]
    set boollist (but-first boollist)
  ]

  report boollist
end
@#$#@#$#@
GRAPHICS-WINDOW
1075
10
2573
3219
-1
-1
10.0
1
10
1
1
1
0
0
0
1
0
148
-319
0
0
0
1
ticks
30.0

BUTTON
20
420
84
453
Setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
90
420
153
453
Go
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
5
155
177
188
mean-iterations
mean-iterations
10
1000
320.0
1
1
NIL
HORIZONTAL

SLIDER
5
215
177
248
num-codebooks
num-codebooks
16
8192
100.0
1
1
NIL
HORIZONTAL

SLIDER
5
255
177
288
num-generations
num-generations
20
2000
100.0
1
1
NIL
HORIZONTAL

OUTPUT
225
10
685
525
11

BUTTON
960
215
1072
248
Run Codebook
run-codebook
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

INPUTBOX
690
180
955
240
codebook-id
FFDF9F6ED7FBDCFECCDED9BE5CBE3600
1
0
String

SLIDER
875
10
1047
43
lineup-density
lineup-density
0
1
0.9
0.01
1
NIL
HORIZONTAL

BUTTON
835
55
912
88
Populate
populate-lineup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
5
75
177
108
lineup-width
lineup-width
3
200
149.0
1
1
NIL
HORIZONTAL

SLIDER
5
10
177
43
sight-range
sight-range
0
3
3.0
1
1
NIL
HORIZONTAL

SLIDER
5
115
177
148
trial-increments
trial-increments
3
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
5
315
177
348
selection
selection
0
1
0.2
0.01
1
NIL
HORIZONTAL

PLOT
5
535
1015
815
Fitness
Generation
Fitness
0.0
100.0
0.0
1.0
false
true
"" ""
PENS
"population max" 1.0 0 -955883 true "" ""
"elite mean" 1.0 0 -8630108 true "" ""
"population mean" 1.0 0 -13345367 true "" ""

SWITCH
705
10
867
43
randomly-populate?
randomly-populate?
1
1
-1000

INPUTBOX
700
95
1005
155
lineup-id
03C2F86772864873C76B04BBD4AE5CDCBC43C5
1
0
String

BUTTON
960
175
1072
208
Step Codebook
run-codebook-once (from-hexstring codebook-id (2 ^ (2 * sight-range + 1) ) )
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
5
355
177
388
mutation-count
mutation-count
0
10
2.0
1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

This model attempts to use NetLogo to replicate the findings from Mitchell, Melanie and James P. Crutch. “Evolving Cellular Automata with Genetic Algorithms: A Review of Recent Work.” (2000). It uses a Genetic Algorithm to search for a one dimensional Cellular Automaton that will always converge to all cells being in the same state in which the majority of cells started. It was completed as part of the coursework for the "Introduction to Complexity" class held by Complexity Explorer ( https://www.complexityexplorer.org/courses/119-introduction-to-complexity ) Unit 6: "Cellular Automata".

## HOW IT WORKS

### Gnomes in Hats

In trying to develop some intuition for the problem, I reached for a common setup in mathematical puzzles of Gnomes in Hats (representative example [here](https://www.intelliot.com/2004/09/gnomes-puzzle/) although there are many varieties). So for this assignment, my setup was: you have an odd number of gnomes in a circle where each gnome wears a White hat or a Black hat. Each gnome can only see its own hat and the hats of some number of gnomes to their left and two gnomes to their right and otherwise cannot see any other gnomes nor can they communicate with any gnomes. At each timestep, each gnome can look at the hats they can see, and then all gnomes simultaneously and instantaneously decide to either keep their hat or put on the other color of hat. The goal is for every gnome in the circle to end up wearing the same color of hat that the majority of ALL gnomes in the cirlce were wearing at the very first timestep. Is there a uniform set of rules that every gnome can independently follow to achieve that result?

I thought of each gnome having a "codebook" that every gnome shared and that they could refer to when deciding whether to change hats. "Okay, for me and the six other gnomes I can see, we are in pattern WWWBWWW. Looking up that pattern, the codebook says I should change my hat to White. Got it.". Now, there are stupendously many possible such codebooks, so the assignment is to use a Genetic Algorithm to try to find a codebook gives the gnomes the strategy to succeed.

### Genetic Algorithm

When the model begins, it generates a population of "codebooks" by randomly varying the density between 0 and 1 and generating a random codebook of that density. It then generates a number of random "lineups" by randomly varying the density between 0 and 1 for the configured number of trials. For each codebook in the population, it runs it on each lineup for a random number of iterations drawn from a Poisson distribution with the configured mean. If the codebook successfully classifies the lineup, it increases its fitness. No partial credit is given.

The configured percentage of top fitness codebooks are kept, and new codebooks are generated by crossing over two random codebooks from among the kept elite. Crossover is achieved by slicing the two codebooks in the same random position and combining the two parts together. Then, the new codebook is mutated the configured number of times in random positions.

This new generation of codebooks then repeats the process, until the configured number of generations have passed.

### Representation

As a row of black and white cells, a "lineup" can easily be represented as a binary number. A "lineup id" is the hexadecimal representation of this binary number.

A "codebook" is a list of rules for every possible local neighborhood in the lineup. If there are 7 gnomes in a neighborhood as in the paper, there are 2^7 = 128 possible neighborhoods to have in the codebook. So a codebook can be just a listing of the 128 states that each possible neighborhood generates in the next iteration, in lexicographic order of the neighborhoods from 0000000 to 1111111. This listing itself can be represented as a 128 bit binary number. A "codebook id" is the hexadecimal representation of that binary number.

## HOW TO USE IT

### The Genetic Algorithm component

* `sight-range` controls how many gnomes each gnome can see in each direction. So a "sight range" of 3 would mean each gnome can see 3 gnomes to the left and 3 gnomes to the right (as well as itself) for a total of being able to see 7 gnomes.
* `lineup-width` controls how many "gnomes" are in the circle.
* `trial-increments` controls how much each codebook is tested. For each 0 ≤ _trial_ ≤ `trial-increments`, the algorithm generates a random lineup with _trial_ / `trial-increments` gnomes in black hats (and the rest in in white hats) and then runs the codebook on that lineup.
* `mean-iterations` controls the average number of iterations that the codebook Cellular Automaton will run each iteration before being checked for fitness. As in the referenced paper, this number is drawn from a Poisson distribution instead of being fixed so that the Genetic Algorithm doesn't specialize for only a specific number of iterations.
* `num-codebooks` controls how many "codebooks" are in the population for the Genetic Algorithm.
* `num-generations` controls the number of generations that the Genetic Algorithm will run for.
* `selection` controls the proportion of codebooks with the highest fitness that are kept each generation.
* `mutation-count` controls the exact number of mutations that will occur after each crossover.

### The Lineup / Codebook Sandbox component

* `randomly-populate?` controls whether to randomly populate the initial lineup, which will then update the `lineup-id` to the new lineup, or to use that `lineup-id` to populate the initial lineup.
* `lineup-density` controls what density of white hats to contain in a randomly generated initial lineup.
* `lineup-id` is the hexadecimal representation of the initial lineup. Can be used to set what you want the initial lineup to be.
* `codebook-id` is the hexadecimal representation of what codebook to use to iterate the cellular automata.
* `Step Codebook` steps through a single iteration of the codebook on the current lineup.
* `Run Codebook` runs through a number of iterations of the codebook on the lineup equal to `mean-iterations`.

## THINGS TO NOTICE

The results closely mirror those found in the referenced paper. Early successes are those that always move towards all white or all black. Crossover helps find strategies that can move "mostly black hats" to "all black hats" and "mostly white hats" to "all white hats". The strategies struggle when the initial lineup is close to 50/50 white hat and black hat.

Also, as an interesting aside, in early versions of my model I didn't vary the number of iterations during fitness checking. An interesting strategy that evolved was for all of the gnomes to converge on SOME color, regardless of majority or not, and then "blink" back and forth between the colors, hoping that the simulation ended with the right color showing.

## THINGS TO TRY

At smaller values of `lineup-width`, the model completes quickly and often finds viable solutions.

The Lineup / Codebook sandbox provides a lot of intuiton for the problem.

## EXTENDING THE MODEL

The referenced paper contains many interesting ideas for extending this sort of model. A particular one of interest is that, because the sophisticated strategies get very good at solving low or high density lineups, their fitness seems artificially inflated by continuously testing them on those lineups. So, instead of always testing on a uniform distribution of densities, somehow incrementally increase the difficulty of the configurations that the strategies are tested on. Two possibilites of this are:

  1. Simply narrow the range of densities tested until it gets closer and closer to 50/50; --or--
  2. A more interesting proposal is to have the test lineups go through a genetic algorithm of their own, where the "fitter" ones are the ones that stump the most strategies. Then have the test lineups co-evolve with the strategies to solve them.


## CREDITS AND REFERENCES

Mitchell, Melanie and James P. Crutch. “Evolving Cellular Automata with Genetic Algorithms: A Review of Recent Work.” (2000).

## COPYRIGHT AND LICENSE

### The MIT License (MIT)

Copyright 2021 Brian Stepnitz

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
1
@#$#@#$#@
