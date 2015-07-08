% a-star algorithm

function [sol iter] = a_star(T,N,w,g,len,table)

% inputs
% 1. T = no. of time slots
% 2. N = no. of users
% 3. g = vector of rates of users transmitting together
% 4. w = rate requirement per user

% outputs
% 1. sol = struct containing solution given by the A* algorithm
% 2. iter = number of times the priority queue is accessed to pick the state
%        with highest priority from the queue
 

 open = struct('col',{},'cost',{},'constraints_left',zeros(N,1),'heuristic',{},'assignments',{});
 oc = 0;    % open count
 
 % start state
 oc = oc+1; 
 open(oc) = struct('col',0,'cost',0,'constraints_left', w.*ones(N,1),'heuristic',table.TBA(T,len),'assignments',[]);
 
 iter = 0;
 % iter represents the number of times the priority queue is accessed
 while (isempty(open) == 0)
     
     iter = iter +1;
     % pick state from OPEN with highest priority
     [~, top_id] = min(cat(2,open.cost) + cat(2,open.heuristic));
     s = open(top_id);      % current state
     
     % check if current state is the solution
     if max(s.constraints_left) <= 0
         sol = s;
         break;
     end
     col = s.col+1;
     
     % remove parent state s from OPEN
     open(top_id) = [];
     oc = oc-1;
     
     % generate new states for all possible assignments in s
     for n=1:N
         ns.col = s.col + 1;
         ns.cost = s.cost + n;
         % decide which users to allocate, and update the constraints
         [~, desind] = sort(s.constraints_left,'descend');
         users = desind(1:n);
         rates_met = zeros(N,1);
         rates_met(users) = g(n);
         ns.constraints_left = s.constraints_left - rates_met ;
         % detect heuristic according to sum of constraints left
         summ = sum(ns.constraints_left);
         if col == T
             ns.heuristic = 0;
         else
             ns.heuristic = table.TBA( T-col,find(table.target_arr >= summ, 1 ) );
         end
         ns.assignments = [s.assignments n];
         % if state is a valid option, insert in OPEN
         if (ns.heuristic < inf) && (~((col==T) &&(max(ns.constraints_left)>0))) 
             oc = oc+1;
             open(oc) = ns;
         end  
         
     end 
 end
 
 if(isempty(sol))
    error('error: no solution found');
 end

end
