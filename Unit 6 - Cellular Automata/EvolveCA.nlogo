; MIT License
;
; Copyright (c) 2021 Brian Stepnitz
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
;
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.

; Complexity Explorer "Introduction to Complexity" course Unit 6 "Cellular Automata" homework
; https://www.complexityexplorer.org/courses/119-introduction-to-complexity/segments/11875
;
; Advanced Level
;
; Implement a version of the Evolving Cellular Automata with Genetic Algorithms project
; described in Unit 6.6 and in the paper “Evolving Cellular Automata to Perform Computations:
; A Review of Recent Results” (linked from the Course Materials page). See what results you
; obtain from evolving with small one-dimensional lattices (otherwise, the computation time can
; get very large!). Feel free to share your results on the class forum!

extensions [table]

globals [
  the-lineup
]

breed [codebooks codebook]

codebooks-own [my-rulecode my-fitness]

to setup
  clear-output
  clear-turtles
  clear-all-plots

  resize-world 0 (lineup-width - 1) (1 - num-iterations) 0

  set-current-plot "Fitness"
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Running and displaying a single rule
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to draw-random-lineup [chance]
  clear-patches

  set the-lineup (random-boolstring lineup-width chance)

  draw-lineup the-lineup 0
end

to draw-lineup [lineup row]
  let index 0
  while [index < length the-lineup] [
    if (item index the-lineup) [
      ask patch index (- row) [set pcolor white]
    ]
    set index (index + 1)
  ]
end

to iterate-rule
  let rulecode (encode (2 * sight-range + 1) the-rulecode)

  let iteration 0
  while [iteration < num-iterations - 1] [
    set iteration (iteration + 1)
    set the-lineup (calc-next-lineup rulecode the-lineup)
    draw-lineup the-lineup iteration
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Run the genetic algorithm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to go

  ; make initial codebooks
  create-codebooks num-codebooks [
    set hidden? true
    set my-rulecode (random-boolstring (2 ^ (2 * sight-range + 1)) (random-float 1))
    set my-fitness 0
  ]

  let perfects-count table:make
  let min-fitness-so-far []
  let max-fitness-so-far []

  foreach (range num-generations) [gen ->
    output-print (word "generation: " gen)
    reset-timer

    let total-fitness 0
    ask codebooks [
      set my-fitness (run-trials my-rulecode)
      set total-fitness (total-fitness + my-fitness)
    ]

    output-print (word timer " seconds")

    make-next-generation total-fitness codebooks

    ; survival of the fittest
    ask min-n-of ((1 - selection) * num-codebooks) (codebooks with [my-fitness > 0]) [my-fitness] [
      die
    ]

    let max-fitness [my-fitness] of (max-one-of codebooks [my-fitness])
    set min-fitness-so-far (ifelse-value (is-list? min-fitness-so-far or max-fitness < min-fitness-so-far) [max-fitness] [min-fitness-so-far])
    set max-fitness-so-far (ifelse-value (is-list? max-fitness-so-far or max-fitness > max-fitness-so-far) [max-fitness] [max-fitness-so-far])
    output-print (word "max-fitness: " max-fitness)

    ask codebooks with-max [my-fitness] [
      output-print (word "max-fitness rulecode: " (decode my-rulecode))
      if (my-fitness = 1) [
        let my-rulecode-num (decode my-rulecode)
        let counts table:get-or-default perfects-count my-rulecode-num 0
        table:put perfects-count my-rulecode-num (counts + 1)
      ]
    ]

    let mean-fitness (total-fitness / num-codebooks)
    set min-fitness-so-far (ifelse-value (is-list? min-fitness-so-far or mean-fitness < min-fitness-so-far) [mean-fitness] [min-fitness-so-far])
    set max-fitness-so-far (ifelse-value (is-list? max-fitness-so-far or mean-fitness > max-fitness-so-far) [mean-fitness] [max-fitness-so-far])
    output-print (word "mean-fitness: " mean-fitness)

    set-plot-x-range -0.5 (gen + 0.5)
    set-plot-y-range ((precision min-fitness-so-far 2) - 0.01) ((precision max-fitness-so-far 2) + 0.01)
    set-current-plot-pen "max"
    plotxy gen max-fitness
    set-current-plot-pen "mean"
    plotxy gen mean-fitness
  ]

  foreach sort-by [[pair1 pair2] -> (last pair1 < last pair2)] (table:to-list perfects-count) [pair -> output-print (word "rulecode: " (first pair) " perfect-count: " (last pair))]
end

to make-next-generation [total-fitness curr-generation]
  create-codebooks ((1 - selection) * num-codebooks) [
    set hidden? true

    let p1 (random-float 1)
    let p2 (random-float 1)

    let accumulator 0
    let parent1 []
    let parent2 []
    ask curr-generation [
      let normalized-fitness (my-fitness / total-fitness)
      set accumulator (accumulator + normalized-fitness)

      if (is-list? parent1 and p1 < accumulator) [set parent1 self]
      if (is-list? parent2 and p2 < accumulator) [set parent2 self]
      if (p1 < accumulator and p2 < accumulator) [stop]
    ]

    let rulecode1 ([my-rulecode] of parent1)
    let rulecode2 ([my-rulecode] of parent2)

    let crossover-index (random length rulecode1)

    let cross1 (sublist rulecode1 0 (crossover-index + 1))
    let cross2 ifelse-value (crossover-index < 1 + length rulecode2) [sublist rulecode2 (crossover-index + 1) (length rulecode2)] [ [] ]
    let next-rulecode (sentence cross1 cross2)

    set my-rulecode (mutate-with-chance next-rulecode)
    set my-fitness 0
  ]
end

to-report run-trials [rulecode]
  let total 0
  foreach (range (1 + trial-increments)) [trial ->
    let proportion (trial / trial-increments)
    set total (total + (run-iterations rulecode (random-boolstring lineup-width proportion)))
  ]

  let mean-fitness (total / (1 + trial-increments))
  report mean-fitness
end

; run 'rulecode' on 'start-lineup' for 'num-iterations', report fitness
to-report run-iterations [rulecode start-lineup]
  let iter 0
  let prev-lineup []
  let curr-lineup start-lineup
  while [iter < num-iterations] [
    set prev-lineup curr-lineup
    let next-lineup (calc-next-lineup rulecode curr-lineup)
    set curr-lineup next-lineup
    set iter (iter + 1)
  ]

  let num-true (reduce [ [true-so-far next-item] -> true-so-far + (ifelse-value next-item [1] [0]) ] (fput 0 start-lineup))
  let majority-state (num-true > lineup-width / 2)

  report (calc-fitness majority-state prev-lineup curr-lineup)
end

to-report mutate-with-chance [rulecode]
  report map [
    elem -> ifelse-value (random-float 1 < mutation-chance) [not elem] [elem]
  ] rulecode
end

; compute the proprotion of cells in 'prev-lineup' + 'end-lineup' that are in state 'majority-state'
to-report calc-fitness [majority-state prev-lineup end-lineup]
  let count-state (reduce [[count-so-far curr-state] -> ifelse-value (majority-state = curr-state) [count-so-far + 1] [count-so-far]] (fput 0 (sentence prev-lineup end-lineup)))

  report count-state / (2 * lineup-width)
end

to-report calc-next-lineup [rulecode prev-lineup]
  let half-neighborhood (floor ((2 * sight-range + 1) / 2) )

  ; wrap the lineup around
  let tail (sublist prev-lineup (lineup-width - half-neighborhood) lineup-width)
  let head (sublist prev-lineup 0 half-neighborhood)
  ; it's an ouroboros
  let ring (sentence tail prev-lineup head)

  report last reduce [[neighborhood-lineup-so-far curr-elem] -> calc-next-elem rulecode (first neighborhood-lineup-so-far) (last neighborhood-lineup-so-far) curr-elem] (fput (list [] []) ring)
end

to-report calc-next-elem [rulecode prev-neighborhood next-lineup-so-far curr-elem]
  if (length prev-neighborhood < (2 * sight-range + 1) - 1) [
    ; still building up to first neighborhood
    report (list (lput curr-elem prev-neighborhood) next-lineup-so-far)
  ]

  let neighborhood (ifelse-value (length prev-neighborhood = (2 * sight-range + 1)) [lput curr-elem (butfirst prev-neighborhood)] [lput curr-elem prev-neighborhood])

  let next-elem (eval-rule rulecode neighborhood)

  report (list neighborhood (lput next-elem next-lineup-so-far))
end

; For a one-dimensional cellular automaton with neighborhood size 'n'
; There are 2^n corresponding possible neighborhood configurations
; So there are 2^(2^n) possible rules
; A rulecode is a 2^(2^n) length binary array specifying one of those rules
; The rulecode encodes the next cell state given
; every possible of its neighborhood configuration of the previous state
;
; This function starts with the entire rulecode binary array
; and the entire neighborhood binary array
;
; If the first element in the neighborhood is 1,
; then the state of the cell is given in the first half of the rulecode
; else the state is given in the last half of the rulecode
;
; It then slices the rulecode to that half,
; and slices off the first element of the neighborhood,
; and recurses down
; until the rulecode-slice is a single element,
; which we know will be the next state of the cell
to-report eval-rule [rulecode-slice neighborhood-slice]
  let l length rulecode-slice
  report ifelse-value (l = 1)
  [
        last rulecode-slice
  ]
  [
    ifelse-value first neighborhood-slice
    [
      eval-rule (sublist rulecode-slice 0 (l / 2)) (butfirst neighborhood-slice)
    ]
    [
      eval-rule (sublist rulecode-slice (l / 2) l) (butfirst neighborhood-slice)
    ]
  ]
end

to-report random-boolstring [len proportion]
  let indices (n-of (round (len * proportion)) (n-values len [i -> i]))
  report n-values len [i -> member? i indices]
end

; encode 'num' as an 'arity'-bit boolean string
to-report encode [arity num]
  report pad-to-length (2 ^ arity) (to-boolstring num)
end

; convert 'num' to a boolstring
to-report to-boolstring [num]
  report ifelse-value (num < 1)
  [
    []
  ]
  [
    lput (num mod 2 = 1) (to-boolstring (floor (num / 2)))
  ]
end

; pad 'boolstring' to a one of length 'len'
to-report pad-to-length [len boolstring]
  if (length boolstring > len) [
    error "list too long!"
  ]

  report ifelse-value (length boolstring >= len) [
    boolstring
  ]
  [
    pad-to-length len (fput false boolstring)
  ]
end

; convert boolstring to a number
to-report decode [boolstring]
  report ifelse-value (empty? boolstring) [
    0
  ]
  [
    (2 ^ (length boolstring - 1) * (ifelse-value (first boolstring) [1] [0]))
    + (decode butfirst boolstring)
  ]
end

; convert a boolstring to a bitstring
to-report to-bitstring [boolstring]
  report map [ ?1 -> ifelse-value ?1 [1] [0] ] boolstring
end

; convert a bitstring to a boolstring
to-report from-bitstring [bitstring]
  report map [ ?1 -> ?1 = 1] bitstring
end
@#$#@#$#@
GRAPHICS-WINDOW
750
10
858
319
-1
-1
10.0
1
10
1
1
1
0
1
1
1
0
9
-29
0
0
0
1
ticks
30.0

BUTTON
25
390
89
423
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
95
390
158
423
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
170
177
203
num-iterations
num-iterations
10
1000
30.0
1
1
NIL
HORIZONTAL

SLIDER
5
90
177
123
num-codebooks
num-codebooks
16
8192
1024.0
1
1
NIL
HORIZONTAL

SLIDER
5
250
177
283
num-generations
num-generations
20
2000
128.0
1
1
NIL
HORIZONTAL

SLIDER
5
290
177
323
mutation-chance
mutation-chance
0
1
0.025
0.001
1
NIL
HORIZONTAL

OUTPUT
185
10
555
525
11

BUTTON
645
115
742
148
Iterate Rule
iterate-rule
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
575
10
727
70
the-rulecode
4.009420928E9
1
0
Number

SLIDER
565
75
737
108
init-lineup
init-lineup
0
1
0.55
0.01
1
NIL
HORIZONTAL

BUTTON
560
115
637
148
Populate
draw-random-lineup init-lineup
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
10
177
43
lineup-width
lineup-width
3
99
10.0
1
1
NIL
HORIZONTAL

SLIDER
5
50
177
83
sight-range
sight-range
0
3
2.0
1
1
NIL
HORIZONTAL

SLIDER
5
130
177
163
trial-increments
trial-increments
3
100
20.0
1
1
NIL
HORIZONTAL

SLIDER
5
210
177
243
selection
selection
0
1
0.1
0.01
1
NIL
HORIZONTAL

PLOT
5
535
555
815
Fitness
Generation
Fitness
0.0
100.0
0.0
1.0
false
false
"" ""
PENS
"mean" 1.0 0 -955883 true "" ""
"max" 1.0 0 -8630108 true "" ""

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
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
NetLogo 6.2.0
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
