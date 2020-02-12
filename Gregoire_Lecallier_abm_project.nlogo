breed [followers follower]
breed [explorers explorer]

followers-own [gold risk]
explorers-own [gold ]

to setup
  clear-all
  setup-patches
  setup-followers
  setup-explorers
  setup-risk
  reset-ticks
end

;sets the spots where the gold mines are (the spots remain the same but the amount of gold varies a bit)
to setup-patches
  ask patches [set pcolor brown]
  ask patches with [pxcor < 7 and pxcor > -7 and pycor > 5 and pycor < 11 ][if (random 4) < 3 [set pcolor yellow ]] ;top mine
  ask patches with [pxcor >  -7 and pxcor <  7 and pycor < -10  and pycor > -15 ][if (random 4) < 3 [set pcolor yellow ]] ;bottom mine
  ask patches with [pxcor > 15  and pycor < 7 and pycor > -3 ][if (random 4) < 3 [set pcolor yellow ]] ;right mine
  ask patches with [pxcor < -15 and pycor < 7 and pycor > -3 ][if (random 4) < 3 [set pcolor yellow ]] ;left mine
end


;sets up the followers in green
to setup-followers
    create-followers number-of-followers [set shape "person" set size 1.5 set color green setxy 0 0]
end

;sets up the furthest distance a follower is willing to move from the first gold spot found
to setup-risk
  ask followers [
    set risk random round((count followers) ^ 1.1) + 1
    ;set label risk
  ]
end

;sets up the explorers in blue
to setup-explorers
    create-explorers number-of-explorers [set shape "person" set size 1.5 set color blue setxy 0 0]
end

to go
  if count turtles > 10 [ user-message "No more than 10 turtles" stop ] ;counstraint on the population
  if ticks > 999 [stop] ;time constraint
  eat-gold ;;Collect resource to increase wealth
  move-explorers ;procedure to move explorers
  move-followers ;procedure to move followers
  tick
end

;here we define rules for how the followers move
to move-followers
  ask followers [
    let nearby-gold patches with [pcolor = yellow and distance myself < 1] ; find nearby gold
    let nearby-crowd max-one-of turtles [count neighbors] ;find nearby crowd in order to follow the crowd
    ;let nearby-richer patches in-radius 15 with [pcolor = 34] ; find nearby person who is richer
    let first-gold-found  min-one-of patches with [pcolor = 34] [distance myself] ;find the gold mine discovered

    ifelse any? nearby-gold ; test if the is gold around me
      [face min-one-of nearby-gold [distance myself] fd 0.5] ; then face and move to the closest gold in radius 1 to myself
      [
       ifelse any? patches with [pcolor = 34]  ;if not check if the first spot is discovered
         [
          ifelse distance first-gold-found > risk [face first-gold-found fd 0.5]  ;then do not move too far from the spot found
          [face nearby-crowd right random 360 fd 0.5] ;and look for gold around it without taking much risk
         ]
         [face nearby-crowd fd 0.25 right random 360 fd 0.25];if no gold and no spot found then move around the nearby crowd
     ]
  ]
end

;explorers procedure
to move-explorers
  ask explorers [
    ifelse (count turtles-on neighbors4) > 1 [fd 0.5] ;if there are too much people around go away
    [
      ifelse  count patches in-radius 3 with [pcolor = 36] > 2 and gold > 10 ;if there is gold already found nearby and already rich
      [facexy 0 0 fd 0.5] ;then go somewhere else
         [
        right random 360 forward 0.5 ;otherwise look for gold
         ]
   ]
  ]
end

;turtles procedure to collect gold
to eat-gold
  ask turtles [
    if pcolor = yellow [ ;if turtle on yellow
      ifelse any? patches with [pcolor = 34] [ ;if there is a patch with color 34 in the map
        set pcolor 36 ;then "remove" the yellow patch
        set gold (gold + 10)] ;and collect the gold
      [
        set pcolor 34 ;otherwise if there is no patch with color 34 sets the first gold nugget found to color 34
        set gold (gold + 10)] ;and collect the gold
  ]
     ifelse show-energy? ;asks for observer to show the gold label
      [ set label gold ]
      [ set label "" ]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
391
10
891
511
-1
-1
12.0
1
10
1
1
1
0
0
0
1
-20
20
-20
20
1
1
1
ticks
30.0

BUTTON
66
10
129
43
NIL
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

SLIDER
0
43
172
76
number-of-followers
number-of-followers
0
10
10.0
1
1
NIL
HORIZONTAL

BUTTON
264
11
327
44
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SWITCH
129
10
263
43
show-energy?
show-energy?
0
1
-1000

SLIDER
172
44
344
77
number-of-explorers
number-of-explorers
0
10
0.0
1
1
NIL
HORIZONTAL

PLOT
0
78
266
300
Gold collected
Time
gold
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"followers" 1.0 0 -12087248 true "" "plot sum [gold] of followers"
"explorers" 1.0 0 -13345367 true "" "plot sum [gold] of explorers"

MONITOR
265
211
389
256
Average per explorers
(sum [gold] of explorers) / number-of-explorers
1
1
11

MONITOR
266
166
389
211
Average per followers
(sum [gold] of followers) / number-of-followers
1
1
11

MONITOR
266
121
389
166
Total collected
sum [gold] of turtles
17
1
11

MONITOR
265
297
389
342
Variance explorers
sqrt((variance ([gold] of explorers)) /  (count explorers))
1
1
11

MONITOR
265
254
389
299
Variance of followers
sqrt((variance ([gold] of followers)) /  (count followers))
1
1
11

PLOT
0
301
266
507
% gold collected
Time
NIL
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -1184463 true "" "plot( (sum [gold] of turtles) / (10 * (count patches with [pcolor = yellow]) + sum [gold] of turtles ) )"

MONITOR
266
387
357
432
Richest explorer
max([gold] of explorers)
1
1
11

MONITOR
266
432
357
477
Richest follower
max([gold] of followers\n)
17
1
11

MONITOR
266
78
391
123
Total gold available
10 * (count patches with [pcolor = yellow]) + sum [gold] of turtles
17
1
11

MONITOR
264
342
389
387
overall variance
sqrt((variance ([gold] of turtles)) /  (count turtles))
1
1
11

MONITOR
265
477
369
522
% gold collected
(sum [gold] of turtles) / (10 * (count patches with [pcolor = yellow]) + sum [gold] of turtles)
3
1
11

@#$#@#$#@
## WHAT IS IT?

Search, or seeking a goal under uncertainty, is a ubiquitous requirement of life.
Is it worth following the others and imitate the croud? Or is it more worth exploring new things and taking risks? 
What global impact on the environnment has those two strategies over time according to the global behaviour of the population? 

The gold miner dilemma model tries to answer these questions by simulating a camp of gold miners seeking for gold mines.
In this model there are two kind of gold miners: the followers and the explorers.
The followers don't take much risks and chose to look for gold in known deposits, where other gold nuggets have already been discovered.
On the contrary, explorers take the maximum risk and try to find other unknown deposits.

The objective of this simulation is to find what combination of followers/explorers is the most worth for the community (under the constraint of time and size of the population).

## HOW IT WORKS

The behaviour of each category is as followed:

followers: 
-if no gold deposit is found, followers just copy the others by following the crowd
-if a gold mine is found, followers rush to it and looks for gold around that spot

explorers:
-if there are too many people around, explorers try to look for gold another way
-explorers just move randomly accross the field
-if explorers found a gold deposit that has already been discovered, they try to look for another one

## HOW TO USE IT

The amount of the population is restrained to 10 and the time limit is set to 1000 ticks.

-Sliders allow to vary the number of explorers and followers. The overall population can not be greater than 10

-The gold collected graph allows to compare the amount collected by explorers and followers over time

-Total gold available monitor shows the total gold available on the field before the simulation starts

-Total collected monitor shows the overall amount collected within the population

-Average per followers/explorers monitors compute in real time the avergage gold owned by each category of the population

-Variance of explorers/followers is a representation of the inquality inside each category of the population whereas the overall variance shows the inequality in the overall population

-%gold collected monitor and graph computes the proportion of gold collected over the total gold available at the begining of the simulation. This highlights the effectivness of the global population's behaviour


## THINGS TO NOTICE

Using the behaviour space of Netlogo, we made 100 simulations for each couple followers/explorers allowed by the model (and under the constraint total population = 10).

It appears that the most effective couple, according to the %gold collected score, in average, is 6 followers for 4 explorers (28% of gold collected in average).
We noticed through those simulations that when the proportion of explorers and followers is balanced, the average utility of the population is almost as high.
However the followers appear to be richer than explorers in those balanced cases. And the first followers that arrived in the discovered spot appear to be the richest.
In the very short term, the first explorer has the advantage since he is the one that discovers the deposit.
In the middle term, followers'wealth overtake by far followers's.
However in the long term, explorers take the advantage since the followers farmed and  exploit the gold mine at the maximum.
Notice that the % of gold collected increases as the amount of followers increases but decreases in average if the amount of followers is too high (for a constant amount of population of 10).


## THINGS TO TRY

For each simulation, set the amount of followers/explorers so that they add up to 10.
Try to compare the inequality inside the population of explorers and followers for extrems combinations of followers/explorers.
Compare the % of gold collected by the overall population and notice it should be higher when the ratio of followers/explorers is around 50/50.

## EXTENDING THE MODEL

The model can improve a lot. 
The explorers moving procedure and the structure of the map has to be reconfigured so that it represent more the golbal behaviour of explorers: they take risks so only a few of them should be rewarded. However in this model the variance of explorers seems to be too low, meaning the inquelity in the explorers population is low.
Morover, the results of the model are too much dependant of the set-up of the gold mines positions.
The current set up has been made so that it meets the results excpectation, so the set up of gold mines does not really matches with a scientific experimentation.
As a conclusion the model can be improved by modifying the way explorers move and disposition of the gold mines, so that it respects more a scientific method.

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

The video that motivated the project idea (really intersting!):
 
https://www.youtube.com/watch?v=asHiYmdk9W0&t=311s

Original James March research article about Exploration and Exploitation in Organizational Learning:

https://pubsonline.informs.org/doi/abs/10.1287/orsc.2.1.71

Other article about the same subject:

https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4410143/
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
NetLogo 6.1.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="2" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>(sum [gold] of turtles) / (10 * (count patches with [pcolor = yellow]) + sum [gold] of turtles)</metric>
    <metric>(sum [gold] of followers) / number-of-followers</metric>
    <metric>(sum [gold] of explorers) / number-of-explorers</metric>
    <metric>sqrt((variance ([gold] of followers)) /  (count followers))</metric>
    <metric>sqrt((variance ([gold] of explorers)) /  (count explorers))</metric>
    <metric>sqrt((variance ([gold] of turtles)) /  (count turtles))</metric>
    <metric>max([gold] of followers)</metric>
    <metric>max([gold] of explorers)</metric>
    <enumeratedValueSet variable="number-of-followers">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-energy?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-explorers">
      <value value="8"/>
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
0
@#$#@#$#@
