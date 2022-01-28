;********************************************************
; FILENAME: iFinder-Discovery.nlogo
; DATE    : 15/07/2021, 16:13PM
; AUTHOR  : Syed Kaleem Aslam
;
; DESCRIPTION:
; -------------------------------------------------------
; A base for loading in patch data from external files.
; Data can be loaded from files and then patch data in
; in this model can be coloured in via those data values.
;
; NAMESPACES:
; -------------------------------------------------------
; ENVLOAD :: environment-loader.nls
; EVO     :: evolution.nls
;********************************************************

extensions [jge array]

__includes [ "script-files/environment-loader.nls" "script-files/evolution.nls" "script-files/explorer.nls" "script-files/logger.nls"]

breed [explorers explorer]


;Give the only robots used variables which facilitate the use of evolutionary algorithms
explorers-own [
  genotype               ;; The genome of the robot.
  phenotype              ;; The program of the robot.
  valid?                 ;; True if the phenotype of the robot is not a valid program.
  fitness                ;; The raw fitness value of the robot.
  moves                  ;; How many moves/steps the robot did.
]


;Give patches their own GLOBAL queryable variables
patches-own [
  goal-location? ;Does the patch contain the (or part of the) goal state?
  is-wall?       ;Is the patch an obstacle (WALL) or is it an unobstructed space
  is-mat?
  is-mat2?
  is-mat3?
  is-mat4?

  Pcounter
  counter1
]



globals [

  found-goal-state?
  obstacle-infront-counter
  turn-counter

  current-run             ;; Monitor variable. Reports the number of the current run of an experiment.
  current-generation      ;; Monitor variable. Reports the number of the current generation of the current run of an experiment.
  fitness-score           ;; Monitor variable. The fitness value of the best robot of the current generation.
  solution                ;; An array with the properties of the best robot of the current generation:
                          ;; 0-genotype, 1-phenotype, 2-valid?, 3-fitness, 4-moves.
  solution-best           ;; An array with the properties of the best robot (solution) found so far in all runs:
                          ;; 0-genotype, 1-phenotype, 2-valid?, 3-fitness, 4-moves.

  steps                   ;; Monitor variable. Steps performed so far by the robot in one simulation.


  population              ;; An ordered array of the population (robots) sorted by the fitness value (from max to min).
  valid-robots            ;; The number of valid individuals of the current generation.

  success-frequency-array ;; An array of size Max-Generations + 1. It stores the numbers of successful runs in the corresponding generations (index) they ended.
  fitness-frequency-array ;; An array of size garbage-amount + 1. It stores the numbers of robots generated so far with the corresponding fitness values (index).


  ;Buttons Flags (0 for false and 1 for true - Default value is 0)
  setup-pressed           ;; True if "setup" button has been pressed.
  run-pressed             ;; True if "go" button has been pressed and finished.
  setup-sft-pressed       ;; True if "setup sft" button has been pressed.

  calculation
  entropy
  ;cpc
  ;calc

  ;Left-Turn-Angle
  ;Right-Turn-Angle
]




;-----------------------------------------------------
; FUNCTION: init-variables
; ---------------------------------------------------
;
; DESCRIPTION:
; ----------------------------------------------------
; Initialises all global variables in one convenient place
;-----------------------------------------------------
TO INIT-VARIABLES

  set current-run 0
  set current-generation 0
  set fitness-score 0
  set solution array:from-list ["" "" false 0 0]
  set solution-best array:from-list ["" "" false 0 0]
  set steps 0
  set population array:from-list []
  set valid-robots 0

  set found-goal-state? false
  set obstacle-infront-counter 0
  set turn-counter 0

END




;-----------------------------------------------------
; FUNCTION: setup-experiment
; ---------------------------------------------------
;
; DESCRIPTION:
; ----------------------------------------------------
; Does all the necessary start up operations, from
; setting up the patches for the right environment
; to loading in the BNF grammar.
;-----------------------------------------------------
TO SETUP-EXPERIMENT
  clear-all
  ;Colour the patches
  SETUP-PATCHES
  ;Load in the robot
  ;CREATE-EXPLORER-BOT

  EVO::LOAD-BNF-RULES
  INIT-VARIABLES

  set setup-pressed 1
  set run-pressed 0
  set setup-sft-pressed 0

;  set Left-Turn-Angle random 180 + 1
;  set Right-Turn-Angle random 180 + 1

  reset-ticks
END


;-----------------------------------------------------
; FUNCTION: run-experiment
; ---------------------------------------------------
;
; DESCRIPTION:
; ----------------------------------------------------
; The main entry point into the application. This starts
; the chain events which evolve, evaluate, breed and
; kill individuals which eventually results in
; a grammar which can be used in real-life robots.
;-----------------------------------------------------
TO RUN-EXPERIMENT

  if setup-pressed = 0 [
    print "MESSAGE: Press first the \"Setup\" button."
    stop
  ]

  clear-turtles
  clear-drawing


  set steps 0
  set found-goal-state? false
  set obstacle-infront-counter 0
  set turn-counter 0



  if current-run = maximum-runs [
    LOG::PRINT-EXPERIMENT-RESULTS
;    print (word "Turn-Right-Angle is: ="  Right-Turn-Angle)
;    print (word "Turn-Left-Angle is: ="  Left-Turn-Angle)
    output-print array:item solution-best 1
    set steps array:item solution-best 4
    ;set garbage-collected array:item solution-best 3
    set current-run 0
    set current-generation 0
    set fitness-score 0
    set setup-pressed 0
    set run-pressed 1
    stop
  ]

  ask turtles
  [
    count-visits
  ]

  ask turtles
  [
    count-visits

  ]
  set current-run current-run + 1
  set current-generation 0
  set fitness-score 0
  set solution array:from-list ["" "" false 0 0]

  ;setup-bpg-plot
  EVO::CREATE-POPULATION population-size
  EVO::STEADY-STATE-GENETIC-ALGORITHM

  ;Update best solution so far
  set solution-best EVO::COMPARE-FITNESS solution solution-best


END





;-----------------------------------------------------
; FUNCTION: setup-patches
; ---------------------------------------------------
;
; DESCRIPTION:
; ----------------------------------------------------
; A helper method which sets up the patches according
; to which environment is selected in the configuration
;-----------------------------------------------------
TO SETUP-PATCHES
    ENVLOAD::SET-PATCH-COLOURS test-environment
    CLASSIFY-WALLS
    CLASSIFY-GOAL-STATE
    CLASSIFY-MAT
    CLASSIFY-MAT2
    CLASSIFY-MAT3
    CLASSIFY-MAT4
END


;-----------------------------------------------------
; FUNCTION: classify-walls
; ---------------------------------------------------
;
; DESCRIPTION:
; ----------------------------------------------------
; Based on patch colours, this determines if a patch
; is a wall or not, and saves the decision in the patch
; information.
;-----------------------------------------------------
TO CLASSIFY-WALLS
  ask patches [
    ifelse (pcolor = 15)
      [set is-wall? true]
      [set is-wall? false]
  ]
END


TO CLASSIFY-MAT
  ask patches [
    ifelse (pcolor = 2)
      [set is-mat? true]
      [set is-mat? false]
  ]
end

TO CLASSIFY-MAT2
  ask patches [
    ifelse (pcolor = 4)
      [set is-mat2? true]
      [set is-mat2? false]
  ]
end

TO CLASSIFY-MAT3
  ask patches [
    ifelse (pcolor = 6)
      [set is-mat3? true]
      [set is-mat3? false]
  ]
end

TO CLASSIFY-MAT4
  ask patches [
    ifelse (pcolor = 8)
      [set is-mat4? true]
      [set is-mat4? false]
  ]
end




;-----------------------------------------------------
; FUNCTION: classify-goal-state
; ---------------------------------------------------
;
; DESCRIPTION:
; ----------------------------------------------------
; Based on patch colours, this determines if a patch
; is a goal or not, and saves the decision in the patch
; information.
;-----------------------------------------------------
TO CLASSIFY-GOAL-STATE
  ask patches [
    ifelse (pcolor = 88)
     [ set goal-location? true ]
     [ set goal-location? false ]
  ]
END


to count-visits

  if count turtles-here > 0 [
    set Pcounter (Pcounter + 1)
    set plabel Pcounter
  ]

;;highlights the patches with a certain number of visits
 ; if Pcounter > 25 [set pcolor lime]
end


;-----------------------------------------------------
; FUNCTION: create-explorer-bot
; ---------------------------------------------------
;
; DESCRIPTION:
; ----------------------------------------------------
; Create 1 robot with set start properties.
;-----------------------------------------------------
TO CREATE-EXPLORER-BOT
    create-turtles 1 [
    set shape "explorer"
    set size 2
    set xcor 28
    set ycor -28
    set heading 315
    set color blue
   ]
END
@#$#@#$#@
GRAPHICS-WINDOW
495
10
940
456
-1
-1
12.5
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
34
-34
0
0
0
1
ticks
30.0

SLIDER
370
90
480
123
crossover
crossover
0
1
0.68
0.01
1
NIL
HORIZONTAL

SLIDER
370
150
480
183
mutation
mutation
0
1
0.55
0.01
1
NIL
HORIZONTAL

INPUTBOX
950
10
1155
70
BNF-Grammar-Definition-Path
BNF/interesting-grammar-example-2.bnf
1
0
String

BUTTON
10
41
77
76
Setup
setup-experiment
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
85
40
147
76
Run
run-experiment
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
370
270
480
303
codon-size
codon-size
1
16
9.0
1
1
Bits
HORIZONTAL

SLIDER
370
210
480
243
codon-max
codon-max
1
50
24.0
1
1
NIL
HORIZONTAL

SLIDER
370
330
480
363
codon-min
codon-min
1
50
3.0
1
1
NIL
HORIZONTAL

MONITOR
15
310
155
355
Current run #
current-run
10
1
11

MONITOR
15
360
155
405
Current generation
current-generation
17
1
11

MONITOR
15
410
155
455
Best Fitness
fitness-score
17
1
11

SWITCH
10
90
160
123
show-output
show-output
0
1
-1000

BUTTON
1025
75
1155
108
Run Solution
EVO::solution-simulation
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
10
130
160
163
draw-trail
draw-trail
0
1
-1000

MONITOR
15
260
155
305
Steps taken
steps
17
1
11

BUTTON
950
75
1020
108
Setup Trail
EVO::setup-simulation-trail
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
175
45
355
71
Max # of times to run:
12
0.0
1

SLIDER
175
60
360
93
maximum-runs
maximum-runs
1
100
5.0
1
1
NIL
HORIZONTAL

TEXTBOX
175
105
355
131
Max # of generations per pop:
12
0.0
1

SLIDER
175
180
360
213
population-size
population-size
1
1000
20.0
1
1
NIL
HORIZONTAL

TEXTBOX
175
165
325
183
# of individuals in a pop:
12
0.0
1

SLIDER
175
240
360
273
maximum-step-count
maximum-step-count
0
500
300.0
10
1
NIL
HORIZONTAL

TEXTBOX
175
225
370
251
Max # of steps an agent may do:
12
0.0
1

SLIDER
175
300
360
333
generation-gap
generation-gap
0.01
1
0.87
0.01
1
NIL
HORIZONTAL

TEXTBOX
175
285
425
311
The gap between generations:
12
0.0
1

SLIDER
175
360
360
393
maximum-wraps
maximum-wraps
0
50
5.0
1
1
NIL
HORIZONTAL

TEXTBOX
175
345
355
363
Max # of rule wraps to follow:
12
0.0
1

TEXTBOX
370
75
520
93
Crossover rate:
12
0.0
1

TEXTBOX
370
135
520
153
Mutation rate:
12
0.0
1

TEXTBOX
370
255
520
273
Genome codon size:
12
0.0
1

TEXTBOX
370
315
520
333
Min codon len:
12
0.0
1

TEXTBOX
375
195
525
213
Max codon len:
12
0.0
1

TEXTBOX
15
465
365
506
Application output:
12
0.0
1

OUTPUT
10
490
1165
650
12

TEXTBOX
175
10
445
56
Evolutionary Parameters:
20
0.0
1

TEXTBOX
15
225
165
246
Statistics:
20
0.0
1

TEXTBOX
15
10
165
31
Controls:
20
0.0
1

CHOOSER
10
170
167
215
test-environment
test-environment
"easy" "normal" "hard" "Interesting" "Test-Environment"
4

INPUTBOX
950
165
1170
415
custom-code
ROBOT::FORWARD ifelse (ROBOT::COLOUR-AHEAD? 9.9 ) [  ROBOT::RIGHT  25   ][  ROBOT::FORWARD ]\n\nifelse (ROBOT::COLOUR-AHEAD? 55 ) [  ROBOT::LEFT  75   ][  ROBOT::FORWARD ] ROBOT::FORWARD
1
1
String

BUTTON
950
130
1057
163
Custom Setup
EVO::SETUP-CUSTOM-SIM-TRAIL
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
175
125
360
158
maximum-generations
maximum-generations
0
200
10.0
1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

This “iFinder-Discovery” application is a platform-independent implementation of the
steady-state genetic algorithm. Using a range of user interface components, it allows users to choose from a range of configurations which affect the state of an evolutionary process. While the application rapidly spawns populations of robots to test the environment, it evaluates each individual of those populations with a fitness function to determine which individuals live or die and which are allowed to breed together to generate offspring. At the end of the application, the fittest individuals phenotype is stored in a global variable, which can be extracted by the user to place in the Mindstorm’s control unit.

## HOW IT WORKS

When a user presses the SETUP button, all states and variables are defaulted and ready to be used. This is a just the preservation of resources.

The real magic happens when the user presses the RUN button. On run, all the UI parameters are read in, processed and an evolutionary process begins. Using a steady-state genetic algorithm, populations of individuals spawn and perish, with only the fittest of individuals surviving and reproducing.

Once the execution has met the criteria set by the parameters, the application will stop and the phenotype (solution code) of the fittest individual will be returned. Usually this solution-code will indicate the most interesting behaviours created by a robot.

------------------------------------------------------------------------------------------------------------------------------
Parameters:

The RUNS slider controls the number of evolutionary runs to be performed during the execution of the model / experiment.

The MAX-GENERATIONS slider controls how many generations will be created during an evolutionary run.

The POPULATION-SIZE slider controls the size of the population (number of robots).

The GENERATION-GAP slider controls the percent of the parent population to be replaced by the offspring.

The ANT-MAX-STEPS slider controls the limit of moves allowed to perform an ant during the Artificial Ant (Santa Fe Trail) simulation.

The CROSSOVER slider controls the crossover probability during the combination of two offspring.

The MUTATION slider controls the mutation probability applied in the offspring.

The CODON-SIZE slider controls of how many bits consists a codon of the genotype of an ant.

The CODONS-MIN slider controls the down limit of the number of codons of the genotype when the first random population is created in each evolutionary run (smallest possible genotype size of an ant of the initial population).

The CODONS-MAX slider controls the upper limit of the number of codons of the genotype when the first random population is created in each evolutionary run (largest possible genotype size of an ant of the initial population).

The MAX-WRAPS slider controls the maximum number of wraps of the genotype allowed during the genotype-to-phenotype mapping process.

The BNF-GRAMMAR-DEFINITION-PATH input defines the path where the file with the BNF grammar definition used by the Grammatical Evolution algorithm is stored. The path can be absolute or relative to the path of the model.

The TEST-ENVIRONMENT option allows users to select what environment they evolve their behaviour for, so they can examine how well parameters work for different maps.

## HOW TO USE IT

The majority of UI controls are sliders, and thus are easy to use and get to grips with; by moving the slider from side to side it is very easy to choose the configuration that is required. When these parameters have been finalised, the user should decide if they wish to view the path the robot has taken by using the draw-trail switch. After this, it is up to the user to choose between any 1 of the 3 environment pre-sets: either easy, normal or hard. Once done the user should hit setup, followed by run. When the evolutionary process is complete, the run button will change from its active black colour to the default colour of purple, and also there should be a phenotype string displayed in the output box. This stringwill be the fittest as determined by the application. To see the behaviour running, users simply need to press setup-trail and
then run-solution.

## THINGS TO NOTICE

Play around with the parameters, what do you notice? Do solutions generated quickly match how you as a human would have solved it compared to runs which have been running for a long time?

## THINGS TO TRY

To view the patterns of each robot of each generation, turn on path drawing and slow the speed right down so you can examine how robot behaviour progresses over time.

Alternatively, turn 'view-updates' off to quickly obtain grammars and build up a list of different grammars for comparison.

## EXTENDING THE MODEL

Try adding more environments of varying complexity or layouts to see how behaviours compare to the preset ones, do simpler or more complex environments generate the best sort of grammar?

Alternatively, how about modifying the code so that 1 run would evolve across all environments, and then merge the results to obtain the all time fittest. This could lead to some very interesting results.

## NETLOGO FEATURES

From the task section of NetLogo, the RUN command is used to simulate NetLogo code amongst code which is already executing. Nothing is performed concurrently, but normal execution flow is halted while the code supplied to the RUN command completes.

The array extension is used for more efficient storing of information but for additional features of easy sorting and quicker access.



## RELATED MODELS

A garbage collection model used in Laboratory 3 was the big foundation of this code. Using a steady-state genetic algorithm, agents were evolved with the main purpose of cleaning up rubbish in the most efficient way.

## CREDITS AND REFERENCES

Credit is given to both Loukas Georgiou, Llifon Jones and Dr. Teahan whose NetLogo applications proved to be a great foundation for this work, specifically work related to the steady-state algorithm and roulette-wheel selection method.
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

explorer
true
5
Rectangle -6459832 true false 195 60 255 255
Rectangle -6459832 true false 45 60 105 255
Line -16777216 false 45 75 255 75
Line -16777216 false 45 105 255 105
Line -16777216 false 90 60 255 60
Line -16777216 false 45 240 255 240
Line -16777216 false 45 225 255 225
Line -16777216 false 45 195 255 195
Line -16777216 false 45 150 255 150
Polygon -10899396 true true 90 60 75 90 75 240 120 255 180 255 225 240 225 90 210 60
Polygon -16777216 false false 225 90 210 60 211 246 225 240
Polygon -16777216 false false 75 90 90 60 89 246 75 240
Polygon -16777216 false false 89 247 116 254 183 255 211 246 211 211 90 210
Rectangle -16777216 false false 90 60 210 90
Rectangle -1184463 true false 180 30 195 90
Rectangle -16777216 false false 105 30 120 90
Rectangle -1184463 true false 105 45 120 90
Rectangle -16777216 false false 180 45 195 90
Polygon -16777216 true false 195 105 180 120 120 120 105 105
Polygon -16777216 true false 105 199 120 188 180 188 195 199
Polygon -16777216 true false 195 120 180 135 180 180 195 195
Polygon -16777216 true false 105 120 120 135 120 180 105 195
Line -1184463 false 105 165 195 165
Circle -16777216 true false 113 226 14
Polygon -1184463 true false 105 30 60 45 60 60 240 60 240 45 195 30
Polygon -16777216 false false 105 30 60 45 60 60 240 60 240 45 195 30
Rectangle -1 true false 120 135 180 165
Rectangle -16777216 false false 120 135 180 165
Circle -2674135 true false 120 120 30
Circle -2674135 true false 150 120 30
Rectangle -1 true false 120 135 180 150

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

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="Test Experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup-experiment</setup>
    <go>run-experiment</go>
    <metric>dirt-cleaned</metric>
    <metric>steps</metric>
    <enumeratedValueSet variable="Max-Generations">
      <value value="11"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Codons-Min">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Robot-Max-Steps">
      <value value="6000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Show-Output">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Codon-Size">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Crossover">
      <value value="0.9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Mutation">
      <value value="0.97"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="BNF-Grammar-Definition-Path">
      <value value="&quot;bnf/grammar.bnf&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Population-Size">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Ant-Trail">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Generation-Gap">
      <value value="0.9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Runs">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Codons-Max">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Max-Wraps">
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
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
