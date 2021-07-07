function out = absMax(num)
%ABSMAX Summary of this function goes here
%   Detailed explanation goes here
[~,index] = max(abs(num));
out = num(index);
end

