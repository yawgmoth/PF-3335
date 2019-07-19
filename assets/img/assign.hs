module Main where

import Data.List
import Data.Ord

s 0 = "student 0"
s 1 = "student 1"
s 2 = "student 2"
s 3 = "student 3"
s 4 = "student 4"
s 5 = "student 5"
s 6 = "student 6"
s 7 = "student 7"
s 8 = "student 8"
s 9 = "student 9"
s 10 = "student 10"

t 0 = "AI Behavior"
t 1 = "Planning"
t 2 = "Narrative"
t 3 = "Intentionality"
t 4 = "Beliefs"
t 5 = "Game trees"
t 6 = "Machine Learning"
t 7 = "Neural Networks"
t 8 = "Vector Models"
t 9 = "Reinforcement Learning"
t 10 = "Unsupervised Learning"

u 0 4 =  1.00
u 0 3 = 0.66
u 0 8 = 0.33
u 0 _ = -1.0

u 1 7 =  1.00
u 1 4 = 0.66
u 1 10 = 0.33
u 1 _ = -1.0

u 2 0 =  1.00
u 2 2 = 0.66
u 2 8 = 0.33
u 2 _ = -1.0

u 3 2 =  1.00
u 3 3 = 0.66
u 3 1 = 0.33
u 3 _ = -1.0

u 4 7 =  1.00
u 4 0 = 0.66
u 4 3 = 0.33
u 4 _ = -1.0

u 5 4 =  1.00
u 5 5 = 0.66
u 5 6 = 0.33
u 5 _ = -1.0

u 6 8 =  1.00
u 6 10 = 0.66
u 6 9 = 0.33
u 6 _ = -1.0

u 7 2 =  1.00
u 7 0 = 0.66
u 7 3 = 0.33
u 7 _ = -1.0

u 8 6 =  1.00
u 8 4 = 0.66
u 8 1 = 0.33
u 8 _ = -1.0

u 9 7 =  1.00
u 9 2 = 0.66
u 9 0 = 0.33
u 9 _ = -1.0

u 10 4 =  1.00
u 10 8 = 0.66
u 10 7 = 0.33
u 10 _ = -1.0

u 11 7 =  1.00
u 11 10 = 0.66
u 11 0 = 0.33
u 11 _ = -1.0

u 12 5 =  1.00
u 12 1 = 0.66
u 12 3 = 0.33
u 12 _ = -1.0

u _ _ = 0.0

utility :: [(Int,Int)] -> Double
utility assignments = sum $ map (uncurry u) assignments

makeAssignment :: [Int] -> [Int] -> [(Int,Int)]
makeAssignment students topics = maximumBy (comparing utility) assignments
                              where 
                                  assignments = map (zip students) $ permutations topics
                                  
formatAssignment :: [(Int,Int)] -> String
formatAssignment assignment = (intercalate "\n" $ map showAssignment assignment) ++ ("\nScore: " ++ (show $ utility assignment))
                           where 
                               showAssignment (st,to) = (s st) ++ ": " ++ (t to) ++ " (" ++ (show $ u st to) ++ ")"

main = do 
          putStrLn $ formatAssignment $ makeAssignment [0..10] [0..10]