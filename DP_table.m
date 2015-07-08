% computing the DP table

function [table len sol_idx] = DP_table(T,N,g,w,step_size)

% inputs
% 1. T = no. of time slots
% 2. N = no. of users
% 3. g = vector of rates of users transmitting together
% 4. w = rate requirement per user
% 5. step_size = quantum into which the rate requirement is discretized

% outputs
% 1. table = DP table with fields:
% target_arr = vector of the rates fulfilled corresponding to columns of the table
% curr(i,j) = no. of users alloted to cell(i,j) of the table
% prev(i,j) = choice of solution from previous time slot corresponding to cell(i,j) of the table
% TBA(i,j) = Total Bins Alloted = optimal cost corresponding to cell(i,j)
% gain(i,j) = sum of gains achieved for all the users corresponding to cell(i,j)
% 2. len = column of DP table which satisfies the sum-constraint for T slots
% 3. sol_idx = index of cell(if it exists) of DP table which satisfies each user's
% constraints

 gt=g.*(1:N);       % overall rate achieved in 1 slot for different no. of users transmitting
 gt_app = [0 gt];
 wt=N*w;            % total rate requirement of all users
 
 
 % error check: upper bound: tight if max(gt) corresponds to N users
 if (wt > max(gt)*T)
     error('Desired rate cannot be achieved');
 end
 
% discretize the gain requirement
target_arr = (step_size : step_size : ceil(wt/step_size)*step_size);
len = length(target_arr);       % no. of columns in the DP table
target_max = max(gt)*T;
target_arr = (step_size: step_size: ceil(target_max/step_size)*step_size);  % extend DP table to allow overfitting
lenx = length(target_arr);      % no. of columns in DP table to allow overfitting

% matrix space allocation
 temp=zeros(T,lenx);
 table = struct('target_arr',target_arr,'curr',temp,'prev',temp,'TBA',inf*ones(T,lenx),'gain',temp);
 user_req = cell(T,lenx);
 for i=1:T
     for j=1:lenx
         user_req{i,j} = w*ones(N,1);
     end
 end
 
 % base case
 k=1;
 while((k <= lenx) && (target_arr(k) <= max(gt)))
     ind = find(gt >= target_arr(k), 1 );
     table.curr(1,k) = ind;
     table.TBA(1,k) = ind;
     table.gain(1,k) = gt(ind);
     % split among users
     user_req{1,k} = user_req{i,k} - [g(ind)*ones(ind,1);zeros(N-ind,1)];
%       doesnot account for ind = 0;
     k=k+1;
 end
 
 
 % recursion
 sol_idx = [T len];
 for t=2:T           
     % per time slot
     for k=1:lenx       
         % per target rate level
         target = target_arr(k);
         % move to next time slot if target is not attainable
         if (target > (max(table.gain(t-1,:)) + max(gt)))  
                break;
         end
         % for each possible entry in new slot, pick corresponding soln from
         % previous slots to meet the target gain
         for n=0:N
             m=n+1;
             gain_rem = target - gt_app(m);
             if (gain_rem <= max(table.gain(t-1,:)))
                 prev_sol(m) = find(table.gain(t-1,:) >= gain_rem, 1 );
                 net_cost(m) = n + table.TBA(t-1,prev_sol(m));
             else
                 net_cost(m) = inf;
             end
             
         end
         % choose soln that uses minimum no. of total bins
         [p q] = min(net_cost);
         num_users = q-1;
         table.curr(t,k) = q-1;
         table.prev(t,k) = prev_sol(q);
         table.TBA(t,k) = p;
         table.gain(t,k) = gt_app(q) + table.gain(t-1,prev_sol(q));
         % split among individual users
         if num_users == 0
             user_req{t,k} = user_req{t-1,k};
         elseif num_users > 0
             [~, desind] = sort(user_req{t-1,prev_sol(q)},'descend');
             users = desind(1:num_users);
             rates_met = zeros(N,1);
             rates_met(users) = g(num_users);
             user_req{t,k} = user_req{t-1,prev_sol(q)} - rates_met;
         end
         if (t==T && k>= len && max(user_req{i,k}) <= 0)
             sol_idx = [t k];
             break;
         end
         
     end
 end