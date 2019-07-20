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

In the project for the class the students will develop a simple planner in python. To do this, the students will develop four separate modules, each with its own requirements and deadline:

 1. A representation of logical formulas, due ??, worth 15 points (+ optionally 5 bonus points)
 2. A search algorithm, due ??, worth 15 points
 3. A parser for PDDL planning domains and problems, and the planner itself, due , worth 15 points
 4. A planning heuristic, due ??, worth 10 points

All due dates are given as anywhere-on-earth, i.e. 23:59 UCT-12. See below for the penalty for late submissions.
Submissions should be made by email, and can come in one of two forms:
  - (Preferred) You store your code in a github repository (e.g. by cloning the framework), add me as a contributor, and email me the **hash** of the commit to use for your submission
  - Email me a zip file containing all source code **in the root directory**, named `carne_n.zip`, where `carne` should be replaced with your Carn&eacute;, and `n` should be replaced with 1,2,3, or 4, depending on which submission it is (e.g. `A12345_3.zip` would be the PDDL parser and planner of the student with the Carn&eacute; A12345).
  
Failure to comply with these instructions may result in point deductions.


Framework
---------

The project has to be developed in [http://python.org](python 3), using the framework found [http://github.com](here). The framework requires only a standard python 3 installation, and students are also only allowed to use the python standard libraries. 
The framework consists of several python files, which specify the API to be used by the project (to enable automated testing), which **must not** be modified in any case. Not following the API will result in a point deduction.

The planner to be developed consists of the four modules listed above, and described in more detail below. The first two modules can be developed independently, but the deadlines for their completion suggest that the students 
work on the logical formula representation first. The third module then consists of parsing a standard PDDL file, and storing it in the logical formula representation developed in the first step. At this point, if the previous 
steps have been completed correctly, implementing the planner itself is straightforward, and only requires using the search algorithm using the logical formulas obtained from the PDDL file as nodes and edges for a graph. 
Finally, since this planner will be relatively slow, the students will improve the performance of their planner by implementing a planning heuristic to be used by the search algorithm.

Development and Testing
-----------------------

The main challenge for this project will not be the necessary software engineering effort (my solution has less than 1000 lines, including all comments and test inputs provided in the framework), but developing an understanding 
for the implementation of logic, search, and the planner itself. The framework provides a few test cases, that mostly serve to demonstrate the expected input, and students are expected to come up with their own additional 
tests. Writing tests, and particularly coming up with difficult scenarios, greatly aids understanding the problem to be solved. This is particularly true for the logical reasoning system, and the pathfinding problem. For 
the planner itself, since we are using the PDDL standard, there are many existing problems to be found online. However, since our planner will be not be as full-featured as state-of-the-art planners it may have difficulty 
parsing and solving all of these problems. Below, some problems that should be solvable by our planner are referred to, but students should also write at least one domain and problem of their own.


Logical Formula Representation
------------------------------

The goal of this task is to develop a class structure representing logical formulas and worlds, that support querying whether or not a world models a formula, and applying changes to the world. The input is given as 
an abstract syntax tree of the logical formulas in question. Later on, in task 3, we will generate these abstract syntax trees by parsing PDDL files, but for now we'll just assume that they are provided. The file 
`expressions.py` describes the expected API and provides some examples for the expected capabilities. The students will have to implement the functions 
   
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


Optional, but highly recommended (worth up to 5 bonus points):

   - `when` expressions 
   - Quantifiers `forall` and `exists`
   - Equality
   
Because these three operations simplify domain writing significantly, many standard PDDL input files use them, and by including them, our planner will be able to support these files. And once you have the other operators,
including these three should be fairly straightforward.

Note, if you are wondering why there is this weird extra `-` in the specification of quantified variables: When we parse the PDDL files later on, which are written in a LISP-inspired syntax, we can get the 
Abstract Syntax Tree used in this task almost "for free", but it does include the dash. Rather than complicating the parsing for this edge-case, we will just keep the dash around and ignore it here.

Search Algorithm
----------------



PDDL Parser and Planner
-----------------------

Planning Heuristic and Optimizations
------------------------------------

Planning Competition (Optional)
-------------------------------
 


Late submission policy
----------------------

Every submission is due **before** the end of the day (anywhere-on-earth) as noted above. Late submissions will be given a reduced score, which linearly scales to 0% until 48 hours after the submission deadline, as determined 
by the hour and minute I receive the submission email. For example, if the assignment is submitted exactly 24 hours late, the points will be reduced by 50%, but if the assignment is only submitted 5 hours and 23 minutes late, 
the points will be reduced by 11.2%. Extenuating circumstances may be taken into account, **if and only if** they are discussed with the instructor before the assignment deadline.
