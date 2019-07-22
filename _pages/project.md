---
title: "Project"
layout: single
excerpt: "Details on the project submission"
sitemap: true
permalink: /project/
frontpageorder: 2
categories: [frontpage]
---

Note: Work in Progress.

Overview
--------

In the project for the class you will develop a simple planner in python. To do this, you will develop four separate modules, each with its own requirements and deadline:

 1. A representation of logical formulas, due September 19, 2019, worth 15 points
 2. A search algorithm, due September 27, 2019, worth 15 points
 3. A parser for PDDL planning domains and problems, and the planner itself, due November 8, 2019, worth 15 points
 4. A planning heuristic, due November 22, 2019, worth 10 points
 5. A separate submission to our own internal planning competition (optional), also due November 22, 2019

All due dates are given as anywhere-on-earth, i.e. 23:59 UCT-12. See below for the penalty for late submissions.
Submissions should be made by email, and can come in one of two forms:
  - (Preferred) You store your code in a github repository (e.g. by cloning the framework), add me as a contributor, and email me the **hash** of the commit to use for your submission
  - Email me a zip file containing all source code **in the root directory**, named `carne_n.zip`, where `carne` should be replaced with your Carn&eacute;, and `n` should be replaced with 1,2,3, or 4, depending on which submission it is (e.g. `A12345_3.zip` would be the PDDL parser and planner of the student with the Carn&eacute; A12345).
  
Failure to comply with these instructions may result in point deductions.


Framework
---------

The project has to be developed in [python 3](http://python.org), using the framework found [here](https://github.com/yawgmoth/PF-3335-framework). The framework requires only a standard python 3 installation, and you are also only allowed to use the python standard libraries. 
The framework consists of several python files, which specify the API to be used by the project (to enable automated testing), which **must not** be modified in any case. Each task below mentions the functions that have 
to be present and follow the API described in their docstrings. Not following the API will result in a point deduction. If you have any specific questions about the API, do not hesitate to ask.

The planner to be developed consists of the four modules listed above, and described in more detail below. The first two modules can be developed independently, but the deadlines for their completion suggest that you
work on the logical formula representation first. The third module then consists of parsing a standard PDDL file, and storing it in the logical formula representation developed in the first task. At this point, if the previous 
tasks have been completed correctly, implementing the planner itself is straightforward, and only requires using the search algorithm using the logical formulas obtained from the PDDL file as nodes and edges for a graph. 
Finally, since this planner will be relatively slow, you will improve the performance of your planner by implementing a planning heuristic to be used by the search algorithm. All of these tasks will be described in more detail
below, but note that this description only serves as a quick reference, and is not a complete substitute for the lectures in which the required algorithms and the PDDL file format will be explained in more detail.

Development and Testing
-----------------------

The main challenge for this project will not be the necessary software engineering effort (my solution has less than 1000 lines, including all comments and test inputs provided in the framework), but developing an understanding 
for the implementation of logic, search, and the planner itself. The framework provides a few test cases, that mostly serve to demonstrate the expected input, and you are expected to come up with their own additional 
tests. Writing tests, and particularly coming up with difficult scenarios, greatly aids understanding the problem to be solved. This is particularly true for the logical reasoning system, and the pathfinding problem. For 
the planner itself, since we are using the PDDL standard, there are many existing problems to be found online. However, since our planner will be not be as full-featured as state-of-the-art planners it may have difficulty 
parsing and solving all of these problems. Below, some problems that should be solvable by our planner are referred to, but you should also write at least one domain and problem of their own.


Task 1: Logical Formula Representation
--------------------------------------

The goal of this task is to develop a class structure representing logical formulas and worlds, that support querying whether or not a world models a formula, and applying changes to the world. The input is given as 
an abstract syntax tree of the logical formulas in question. Later on, in task 3, we will generate these abstract syntax trees by parsing PDDL files, but for now we'll just assume that they are provided. The file 
`expressions.py` describes the expected API and provides some examples for the expected capabilities. You will have to implement the functions 
   
   - `make_expression`, which turns an abstract syntax tree into a suitable python object representing an expression
   - `make_world`, which turns a list of atoms and a dictionary of sets into a suitable python object representing a world 
   - `models`, which determines whether a world models an expression, i.e. if the expression holds in that world 
   - `substitute`, which replaces all occurrences of a variable in an expression with a value, and returns a **new** expression with this substitution. This may be used for formulas with quantifiers, but is **required** even if quantifiers are not implemented.
   - `apply`, which applies an effect, expressed as a logical expression with certain restrictions, to a world, and returns a new world

The return values of `make_expression`, `make_world`, `substitute` and `apply` will only be used to pass them into these functions. `models`, on the other hand, **has** to return a truth value, `True` if the world models the 
expression, and `False` otherwise. The format of the Abstract Syntax Tree passed to the `make_*` functions is described in more detail in the doc strings of `expressions.py`, but a typical input could look like this:
```
("and", 
        ("not", ("at", "home", "mickey")), 
        ("or", 
              ("at", "park", "mickey"), 
              ("at", "store", "mickey"), 
              ("at", "theater", "mickey"), 
              ("at", "airport", "mickey")), 
        ("imply", 
                  ("friends", "mickey", "minny"), 
                  ("forall", 
                            ("?l", "-", "Locations"),
                            ("imply",
                                    ("at", "?l", "mickey"),
                                    ("at", "?l", "minny")))))
```

A world consists of a set of atoms, which are what is considered to be true, and everything else is considered to be false (Closed World Assumption).

In addition to the basic operators, you also have to implement:
   - `when` expressions 
   - Quantifiers `forall` and `exists`
   - Equality
   
Because these three operations simplify domain writing significantly, many standard PDDL input files use them, and by including them, our planner will be able to support these files. Once you have the other operators,
including these three should be fairly straightforward.

Note, if you are wondering why there is this weird extra `-` in the specification of quantified variables: When we parse the PDDL files later on, which are written in a LISP-inspired syntax, we can get the 
Abstract Syntax Tree used in this task almost "for free", but it does include the dash. Rather than complicating the parsing for this edge-case, we will just keep the dash around and ignore it here.

Mandatory functions in `expressions.py`, following the API described there:
   - `make_expression`
   - `make_world`
   - `models`
   - `substitute`
   - `apply`

Task 2: Search Algorithm
------------------------

For this task, you will implement a (directed) graph search algorithm, A&ast;, in python. The input to this algorithm is a graph, consisting of nodes/vertices and edges. However, in order to be able to use this search 
algorithm for the planner later, our graphs will not be represented in their entirety in memory, but rather use a [lazy](https://en.wikipedia.org/wiki/Lazy_evaluation) representation. What this means is that our graph 
will be represented by **one** node, which can generate neighboring nodes as needed. This representation is implemented in `graph.py`, and does not have to be modified. If you want to modify `graph.py`, please do not 
change `Node` and `Edge` and their interfaces. When in doubt what you can change, ask. For this task, you only have to implement one function: `astar(start, heuristic, goal)`. This function takes a graph, represented 
by the start vertex/node, a heuristic function, and a goal predicate and searches for a path from the start to **a** node that satisfies the goal predicate. The result of the function should be four values:
   - The path, represented as a sequence of `Edge` objects
   - The total length of the path 
   - The number of nodes visited, i.e. added to the frontier, during search
   - The number of nodes expanded, i.e. removed from the frontier, during search 
If no path is found, the first two values should be `None`, but the number of visited and expanded nodes should still be reported. 

As mentioned above, the graph is not represented explicitly, instead only a single `Node` object is passed to the algorithm, which has a method `get_neighbors` which returns a list of `Edge` objects representing 
outgoing edges. Each `Edge` object stores its target, the cost to use the edge, and its name (used for printing the path). The target is another `Node` object, which can then in turn be asked for its own neighbors, 
and so on. Note that to simplify development, nodes do not need to be cached between calls, and are instead identified by a unique id, which can be obtained from the `get_id` method. `graph.py` shows how this representation 
can be used to represent finite and infinite graphs.

Mandatory function in `pathfinding.py`, following the API described there:
   - `astar`
   
Do **not** remove or change the `default_heuristic` in `pathfinding.py`.

Task 3: PDDL Parser and Planner
-------------------------------

In this task, you will first parse PDDL files and extract formulas as abstract syntax trees, and then use these abstract syntax trees to construct a logical representation of a planning domain and problem. Then you 
will use the search algorithm developed in task 2 to find a sequence of actions that transforms the initial state into a state that satisfies the goal condition.

The first step will be to parse PDDL files, which follow a LISP-inspired syntax, also known as (space-separated, list-supporting) [S-Expressions](https://en.wikipedia.org/wiki/S-expression). The easiest way to parse 
S-expressions is to fist tokenize the input, splitting at spaces, and ensuring that the opening and closing parenthesis are their own tokens (note that the comment character is ; and all lines starting with that character 
should be ignored). It is also recommended to convert all input to lower case, since PDDL is not case-sensitive, and you may encounter domains with capitalized operator names.

Parsing itself uses a stack: Tokens are consumed in sequence, and pushed onto the stack. When a closing parenthesis is encountered, elements are popped from the stack and accumulated in a list until 
the first opening parenthesis is encountered on the stack. Then the resulting list is pushed onto the stack. For example, the token sequence '(' 'and' '(' 'block' 'a' ')' '(' 'not' '(' 'on' 'a' 'b' ')' ')' ')' is parsed
by first pushing '(', 'and', '(', 'block', and 'a' onto the stack, then, when the ')' token is encountered, the items until the first opening parenthesis on the stack are popped and put into the list `['block', 'a']`, 
which is then pushed onto the stack. Then the tokens '(', 'not', '(', 'on', 'a', and 'b' are pushed. The next closing parenthesis, pops items until the next opening parenthesis, resulting in the list `['on', 'a', 'b']`, 
which is pushed onto the stack. At this point our stack consists of:
```
['on', 'a', 'b']
'not'
'('
['block', 'a']
'and'
'('
```
The last two tokens are both closing parentheses, the first of which will take 'not' and `['on', 'a', 'b']` and result in the list `['not', ['on', 'a', 'b']]` (**important**: The existing list is added as a sub-list, you 
must not process it in any special way, just treat it like all other tokens on the stack.), which is then pushed onto the stack. The final closing parenthesis will result in the list 
`['and', ['block', 'a'], ['not', ['on', 'a', 'b']]]`. Note that this is exactly the same format as the functions developed in task 1 expect for logical formulas. 

Once you have converted a PDDL file into an abstract syntax tree, you need to identify the different parts. For an example, refer to `wumpus.pddl` and `wumpusproblem.pddl` in the framework repository. 
The domain file defines types, constants, predicates, and operators (action schemata). Its root node is called `define`, under which there are several sections, some of which are optional:
  - The `domain` section defines the name of the domain
  - The `:requirements` section defines which capabilities the planner has to support for the domain. Our planner will be able to support `:strips`, `:typing`, and `:disjunctive-preconditions`, `:equality`,
    `:existential-preconditions`, `:universal-preconditions`, `:conditional-effects`, and hence `:adl` (which is a combination of the others). 
  - The `:types` section defines which types (sets of objects) exist in the domain, and how the types are related (optional).
  - The `:constants` section defines which (constant) objects exist in the domain, and (optionally) which type they have.
  - The `:predicates` section defines which predicates exist in the domain (optional).
  - Each `:action` section defines one action schema, described in more detail below. The domain may have arbitrarily many action schemata (although there should be at least one, or there can't be any plans).

You may assume that you are only given well-formed PDDL files suitable for your planner, and can therefore ignore validating syntax, the requirements section, predicates, or types. 

An action schema consists of a name, parameters, a precondition and an effect. The parameters are defined as a list of parameter names, optionally with type information. Typing syntax in PDDL is a bit odd: A type is preceded 
by a dash, which **has** to be its own token, surrounded by whitespace, e.g. `?s - Stories`. However, multiple variables (or objects) may be given the same type by using the abbreviated syntax `?a ?b ?c - Stories`, i.e. 
**all** variables preceding the dash will have the type `Stories`. I recommend iterating over the parameter information, accumulating variables in a list, and when a type definition is encountered (a dash followed by a 
type), all variables currently in the list will be assigned that type. Additionally, when the end of the list is reached without encountering another type specification, all remaining variables are assigned the type `""`.
For example:
```
(?who - agent ?from ?to - square ?what)
```
`?who` has type `agent`, `?from` and `?to` both have the type `square`, and `?what` has the type `""`, i.e. no type. Note that the syntax for constants follows the same rules for typing.

The precondition and effect of an action are logical expressions, where the effect will consist of a conjunction of atoms, negations of atoms, forall-quantified expressions, and when-expressions. As with other constraints, 
you can assume that this is the case and do not have to validate it. Note that the action's parameters (if present) will be part of the precondition and/or effect formulas. 

The type hierarchy defines not only which types exist, but also how they are related. The syntax is similar to the typing syntax used elsewhere, but rather than defining types of objects, it defines subtype/supertype relations.
For example 
```
(:types truck
        airplane - vehicle
        package
        vehicle - physobj
        airport
        location - place
        city
        place 
        physobj - object)
```
This defines that all trucks and airplanes are vehicles, all packages and vehicles (and hence all trucks and airplanes) are physical objects, all airports and locations are places, and all cities, places and physical objects 
are objects. It is important to take this information into account, because the type `vehicle` may be references somewhere, but there is no object that explicitely has been assigned the type `vehicle`, only `truck` or 
`airplane`.

The problem file defines objects, the initial state, and the goal condition. The idea between separating the problem from the domain is that the domain only specifies how the world operates, and can be reused for 
multiple different problems. Like the domain, the root node of the problem file is called `define`, with several subsections. The `problem` section defines the name of the problem, while the `:domain` section specifies 
the required domain (this should match the used domain file exactly, but you do not have to validate this). The main sections of the problem file are `:objects`, `:init` and `:goal`. The `:objects` section follows the 
same syntax as the `:constants` section in the domain file, and for our purposes the contents of the two should be merged. The `:init` section consists of a list of atomic formulas, which specify what is true in the 
initial state of the world (everything else is considered to be false, called the [Closed World Assumption](https://en.wikipedia.org/wiki/Closed-world_assumption)). Finally, the `:goal` section contains a single logical 
expression, which defines which states are considered to be goal states.

Your parser should be implemented in the file `pddl.py`, and has to implement two functions:

   - `parse_domain` is passed the file name of a PDDL domain file, and returns a parsed representation of that domain. I recommend returning a list of an action schemata representation, a dictionary mapping types to sets of 
     constants for each type, and the type hierarchy information. Take care to include an extra mapping from the type `""` to a set of all objects.
   - `parse_problem` is passed the file name of a PDDL problem file, and returns a parsed representation of the problem. I recommend returning a dictionary mapping types to sets of objects for each type (same as for the domain),
     a list of atoms representing the initial state, and an expression object (perhaps obtained with `expressions.make_expression`) representing the goal.

The exact return values are up to you, they will be passed to `planner.plan`, where you will have to process them further as you see fit.


The second part of the assignment requires you to implement the actual planning process in `planner.py` in the function `plan`. This process entails two parts:
   - Take the parsed domain and problem and convert them into a graph.
   - Use `pathfinding.astar` to find a plan.
   
It is recommended to create a subclass of `graph.Node` that represents a state in the planning process. This state will get a list of all possible actions, and when `get_neighbors` is called, will use 
these actions to generate all possible successor states. First, to generate the actual list of actions, the action schemata need to be ground, i.e. for each action schema, all possible values for all parameters are 
inserted, resulting in actions free of unbound variables (there may still be variables present, but they will be bound by forall or exists quantifiers). For example, the `move` action schema in the wumpus domain will 
result in 36 ground actions (1 agent times 6 squares times 6 squares). When `get_neighbors` is called, each action's preconditions are checked against the current world, and only actions that can be applied will result 
in a neighbor. In our case the edge leading to that neighbor will always have cost 1, i.e. each action is equally expensive to take. **Important**: We will give each action a name, corresponding to the action schema 
name, followed by the parameter values in the defined order as a parameter list. For example, one ground action resulting from the `move` action schema in the wumpus world would be `move(agent-1,sq-1-1,sq-2-1)`. These 
action names **have to** be used as the edge names in the search process, in order to ensure consistent output.

The id returned by `get_id` of each state should be derived from the atoms that hold in that state, such that any two states with the same collection of atoms compare as equal, but not any others.

When you have defined your planning problem as a graph this way, you need to define a goal, which will make use of the functionality in `expressions.models` to determine whether a given state satisfies the goal condition. 
With the graph defined, and this goal function you should be able to use `pathfinding.astar` directly using the default heuristic. It should return a plan for the wumpus domain consisting of 10 steps:
```
move(agent-1,sq-1-1,sq-2-1)
move(agent-1,sq-2-1,sq-2-2)
shoot(agent-1,sq-2-2,the-arrow,wumpus-1,sq-2-3)
move(agent-1,sq-2-2,sq-2-3)
move(agent-1,sq-2-3,sq-1-3)
take(agent-1,sq-1-3,the-gold,the-gold)
move(agent-1,sq-1-3,sq-2-3)
move(agent-1,sq-2-3,sq-2-2)
move(agent-1,sq-2-2,sq-2-1)
move(agent-1,sq-2-1,sq-1-1)
```

In order to test your planner more, you should try to come up with your own domain and problem. You can also find many planning domains on the internet, a particularly large collection can be found in 
[this repository](https://bitbucket.org/planning-researchers/classical-domains/src/master/). Of these domains, I can particularly recommend those in the `airport` and `airport-adl` directories. The difficulty 
of these problems increases with increasing numbers, but your planner should be able to solve many of the first 10 or 11 in less than 5 seconds. In the next task we will look at how to improve the performance of the 
planner. More complex domains can be found [here](https://github.com/pellierd/pddl4j/tree/master/pddl). Your planner may only be able to solve the first one or two problems of each of these domains, but they 
provide more test cases. Take particular note of the logistics domain, as it uses the type hierarchy mentioned above.

References:
  - [PDDL Specification](http://homepages.inf.ed.ac.uk/mfourman/tools/propplan/pddl.pdf). Note that this is the "official" specification that describes many features our planner will not support.
  - [Writing Planning Domains and Problems in PDDL](https://www.ida.liu.se/~TDDC17/info/labs/planning/writing.html)
  - [Repository of PDDL domains](http://planning.domains/) The whole collection of PDDL files is also available in a [git repository](https://bitbucket.org/planning-researchers/classical-domains/src/master/)
  - [Some more PDDL domains](https://github.com/pellierd/pddl4j/tree/master/pddl)

Mandatory functions in `pddl.py`, following the API described there:
   - `parse_domain`
   - `parse_problem`

Mandatory function in `planner.py`, following the API described there:
   - `plan`

Task 4: Planning Heuristic and Optimizations
--------------------------------------------

In this task you will make your planner faster. The first, most obvious way to do so, is by implementing a planning heuristic instead of using the default heuristic which always returns 0. There is basically an infinite 
number of planning heuristics out there, and this task will require some creativity to determine which one to use. One basic class of heuristics consists of solving a relaxed version of the planning problem, which may 
be done quickly, and use the length of the solution to the relaxed problem as the heuristic value. For example, by ignoring all negative literals, applying actions to states will only ever increase the number of atoms 
that are true. By starting with the set of atoms true in a state, and applying actions until all atoms required by the goal condition have been added, we can get an approximation for how "close" a state is to the goal, 
and use this approximation as our heuristic value. The Fast Forward Planning System, which has performed remarkably well in planning competitions when it was first presented, uses a variant of GraphPlan to solve this 
relaxed problem without negative literals. Prior to that, the HSP planner assigned values to each atom in the goal that approximate how many actions a relaxed solution might need from the current state to make that atom 
true.

For your planner, you should read and understand these heuristics, and implement one of them for your planner. With this modification, your planner should be able to solve more complex problems. For example problems 6, 12 
and 13 from the airport-directory in the PDDL repository should be solved in less than 5 minutes. The sample solution, without any other optimizations, needs 150 seconds for problem 6 (which needed more than 10 minutes with 
the default heuristic), 225 seconds for problem 12 (down from 500 with the default heuristic), and 88 seconds for problem 13 (down from 800 seconds).

Additionally, you are encouraged to implement additional optimization for your planner. One bottleneck in the current version is that all atoms are represented as strings. Because we know the set of all atoms that can possibly 
show up in the planning process, it is possible to map them to integers, which greatly reduces the complexity of comparisons. It is also possible to analyze the planning problem in some detail, for example by identifying which 
predicates never show up as effects, and therefore can never change (like the adjecancy relation in the wumpus domain). By identifying these predicates, it is possible to keep them in a separate set, which eliminates the need 
to copy them when an action is applied to a world. Additionally, we can use this information to discard actions that have preconditions that can never be satisfied (like moving from a square to a non-adjacent square). If you 
have any other ideas for optimizations, feel free to discuss them with me, and/or implement them. If you believe you came up with a good idea, but it may be too experimental, you may want to implement it only for the planning 
competition (See below)

References:
   - [Planning as heuristic search](https://www.cs.toronto.edu/~sheila/2542/s14/A1/bonetgeffner-heusearch-aij01.pdf)
   - [The Fast Forward Planning System](http://www.cs.toronto.edu/~sheila/2542/w06/readings/ffplan01.pdf)
   - [The Fast Downward Planning System](http://gki.informatik.uni-freiburg.de/papers/helmert-jair06.pdf)
   
There are no new mandatory functions for this task, but your planner must now use the `useheuristic` argument of `plan` to allow enabling and disabling of your heuristic.

Task 5: Planning Competition (Optional)
---------------------------------------
 
At the end of the semester, all planners written by the students will be competing against each other to see who was able to get the best performance out of their planner. The system used is simple: The planners will 
be given increasingly complex planning problems, and have 10 minutes (on my computer) to find a solution. For each correct solution found, the planner gets one point, if the time runs out before a solution is found, no 
points are gained. If the planner returns a solution that is invalid (e.g. using actions with unsatisfied preconditions), a point is lost. The winner is the planner with the most points after all domains/problems I have 
prepared have been tested. In case of a tie, the total time needed by the planners will be used to determine the winner among the tied planners.

This competition is similar to how [planning competitions](http://www.icaps-conference.org/index.php/Main/Competitions) at the International Conference on Automated Planning and Scheduling (ICAPS) are run. Because I want to 
encourage you to push the limits of your planners, which may require some more "experimental" modifications, I will allow you to make a separate submission just for the competition. You will be graded on whatever you submit for 
task 4, but if you want to send me a different/modified version for the planning competition to play around with different heuristic or even more adventerous optimizations, you are free to do so. If you don't send me a separate
submission, I will automatically use your submission for task 4.


Late submission policy
----------------------

Every submission is due **before** the end of the day (anywhere-on-earth) as noted above. Late submissions will be given a reduced score, which linearly scales to 0% until 48 hours after the submission deadline, as determined 
by the hour and minute I receive the submission email. For example, if the assignment is submitted exactly 24 hours late, the points will be reduced by 50%, but if the assignment is only submitted 5 hours and 23 minutes late, 
the points will be reduced by 11.2%. Extenuating circumstances may be taken into account, **if and only if** they are discussed with the instructor before the assignment deadline.
