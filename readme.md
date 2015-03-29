Genie
=====
A _Genetic Creature Sonfier_ written in Processing.

![Main screen shot](/screenshots/genie-scrshot-1.png)

Concept
-------

### Overview
The idea is this project is to make musical creatures who's musical nature is their genetics. These creatures exist in a world basically modeled on bacteria. Their genome consists of the following parameters which are stored as numbers between 0.0f and 1.0f:  
	1. Edge col: physical only, no interaction
	2. Shape: physical only
	3. Size: bigger size decreases life span, also gives larger surface area for "bumping" which is detremental to health
	4. Vision: distance creatue can see
	5. Speed: how fast it moves
	6. State aloof
	7. State hungry
	8. State mate: All states added and taken as ratio. E.g. 0.4 + 0.3 + 0.1 = 50%, 37.5%, 12.5% likelihood of state when changing state
	9. Max babies: max number of times this creature can be a partner in mating
	10. Max life: default max life which is subseqeuently affected by size

### States
Each creature has three modes of activity or states:  
	* Aloof
	* Food
	* Mate  
Creatures change state after moving (see -moving- below). The probability of which state is defined by their genes (see above).

### Moving
A creature moves in a two state system, they are either waiting to move or are moving. If they are aloof then they will choose to move away from other close by creatures. If they want food they will move towards nearby food, or randomly if there is no food. If they want to mate they will move towards another creature, otherwise randomly.

### Mating
Creatures reach sexual maturity at age 5. Any two mature creatures who want to mate can mate. They need to be within a certain proximity with each other to do so. This produces one child. The childs gene is determined by splicing the two parent genes together at a randomly decided point.

### Mutating
Every 1 time unit there is a 1% change of a gene mutation in any creature. When a mutation occurs, there is a 30% chance of re-randomisation for each of the ten genome components.

### The world
The world is initially spawned with a certain amount of food. When a creature dies it becomes food, the amount of which is related to its size. 

The world itself enforces certain rules which are -supernatural-. The number of creatures is enforced to be within certain bounds. At the moment these are set to be 10 <= n <= 500.

### Bumping
Introduced to curb overcrowding, "bumping" is a health decrease dealt when creatures' boundary intersects and their intential direction is through the other creature. There are several limits put on the bumping feature:  
	* No more than 80 bumps can be dealt to a creature in one time unit.
	* A creature cannot be continuously bumped for more that 0.3 time units.  

### Death
Creatures can die in any of the following means:  
	1. Starve: run out of food. Actually food replenishes health, which is always decreasing by 0.1 health units per time unit, so it is loss of health.
	2. Old age: each creature has a maximum life span which is determined by its genes. If it reaches this it dies no matter how healthy/well fed it is.
	3. Child birth: Creatures may only have a certain number of children. If it reaches this limit it dies after spawning its last child.  
Supernaturally, creatures can be killed by the user (or god, see below).

![Main screen shot](/screenshots/genie-scrshot-2.png)
![Main screen shot](/screenshots/genie-scrshot-3.png)

User interface
-----------------
At the moment the UI is very basic and doesn't work too well. This is definitely something to be improved.

The controls are mouse and keyboard.
Mouse:  
	* Left click and hold drag the view around
	* Right click and hold changes to view size.  
Keyboard:  
	* Space - Toggle debug information, most noticibly the state names and life time of each creature.
	* d - double the world size. Do this if a population explosion happens.
	* s - _Children of Men_, toggles creatures fertility
	* p - cap population at current size
	* -/+ - decrease/increase time speed
	* g - cycle through "god" states  

### God states
The mouse pointer is actually a large circle which is the god zone. Its size in the world is determined by the view scale as it is projected from our view onto the world as it is scaled.

There are three god states which determine what happens when the mouse left button is clicked:  
	1. Neutral (gray): Benevolence and noninterferience. Nothing happens.
	2. Destroy (red): Angry, all creatures in the god zone are killed and turned into food.
	3. Music (green): Clicking toggles musical interpretation.  

The music god state randomly picks a creature in the god zone with a time interval which is determined by a base value of 2 time units, modified by the speed gene component of the last creature selected. A random musical pitch between 220 and 880 Hz is sent to the audio engine for playing.

The audio engine has been disabled but was tested and worked. The engine of choice is Csound. To be used in Processing, the -csoundo- library was used but it doesn't work well or reliably and so was disabled. This issue must be addressed in a further version.

### Console output
Some statistics are outputed to the console, for example:
> Actors:42, food:20, births:6, mut:8, starv:0, aged:31, childB:0, bumps:35

Actors and food describe the current number of each of these in the world. Births and mut(ations) is the accumulative count of each of these events. The rest except, strav(e), aged, childB(irth) and bumps are the count of deaths by each of these means.

![Main screen shot](/screenshots/genie-scrshot-4.png)