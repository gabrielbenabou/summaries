function [D] = Berg_Michael_Gruppe2_S2_Aufg2(f, x0, h0, n)

% The function returns the extrapolations and discrete errors for the
% function f(x) = ln(x^2) and an x0 = 2

format long;

for i = 1:n
    h = h0/2^(i-1);
    values_before(i) = (f(x0 + h) - f(x0)) / h; 
end


for i = 1:(n-1)
   for j = 1:(n-i)
      values_after(j) = (4^i * values_before(j+1) - values_before(j)) / (4^i - 1);
   end
   values_before = values_after;
end

D = values_after(1);