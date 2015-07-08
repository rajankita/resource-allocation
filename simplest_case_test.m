 % complete file: testing the DP algorithm: simplest case
 % complexity: O(N*NW*T)
 % DP + A star
 
 clc;
 clear all;
 close all;
 
 % inputs
 T=4;               % no. of time slots
 N=3;               % no. of users
 g=[9 8 5];         % rates of users transmitting together
 w=21;              % rate requirement per user
 
 % compute the DP table
 step_size = 2;     % discretization of rate requirement
 [table len sol_idx] = DP_table(T,N,g,w,step_size);
 
% obtain the lower bound from DP table
col = len;
total_cost_lb = table.TBA(T,col);
total_rate_lb = table.gain(T,col);
t=T;
 while(t>0)
     sol_lb(t) = table.curr(t,col);
     col = table.prev(t,col);
     t = t-1;
 end
 
% obtain the upper bound from DP table
if (exist('sol_idx','var')==0)
    error('No solution from DP');
else
col = sol_idx(2);
total_cost_ub = table.TBA(T,col);
total_rate_ub = table.gain(T,col);
t=T;
 while(t>0)
     sol_ub(t) = table.curr(t,col);
     col = table.prev(t,col);
     t = t-1;
 end
end

% get the a-star solution with the DP table as heuristic
[sol_astar iter] = a_star(T,N,w,g,len,table);

 