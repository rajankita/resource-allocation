# resource-allocation
Resource allocation for users in G.Fast <br>
Simplest case: <br>
Assumption 1: All users have equal rate requirement w <br>
Assumption 2: All n-tuples of users sharing a time slot get the same bit-loading <br>

File simplest_case_test is a test file that specifies the inputs :<br>
T = number of time slots<br>
N = number of users<br>
g = vector specifying rates of users transmitting together<br>
w = rate requirement (constraint) of each user<br>

Uses two functions:<br>
1. DP_table : It computes the Dynamic Programming table, given the inputs and the choice for discretization of the users' requirements<br>
2. a_star : It takes as input the DP table, and uses the A* algorithm to find the optimal solution that satisfies each users requirements.<br>

This program basically computes the following:<br>
1. The lower bound solution from DP that satifies the sum-constraint of all uses, but may or may not satisfy each user's individual constraints<br>
2. The upper bound solution from the DP table (by allowing overfitting), that satisfies each user's constraints<br>
3. The optimal solution from the A* algorithm which lies between the lower and upper bounds provided by the DP table.<br>
