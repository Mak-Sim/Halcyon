function [p,q,D_vec,phi]=dp(Value_matrix,Max_step)

[r,c] = size(Value_matrix);

D = zeros(r+1, c+Max_step*2);
D(1,:) = 0;
D(:,[1:Max_step Max_step+c+1:c+Max_step*2]) = NaN;
D(2:(r+1), Max_step+1:Max_step+c) = Value_matrix;

phi = zeros(r,c); %Return indexes

for i = 1:r; 
  for j = Max_step+1:Max_step+c;
    [dmax, tb] = min(D(i, j-Max_step:j+Max_step));
    D(i+1,j) = D(i+1,j)+dmax;
    phi(i,j-Max_step) = tb;
  end
end

%Retrieving the best path
i = r; 
[~,j] = min(D(r+1,Max_step+1:Max_step+c));
p = i;
q = j;
while i > 1 && j >= 1
  tb = phi(i,j);

  i=i-1;
  j=j-(Max_step+1)+tb;
  
  if(j==0)
      break;
  end
  
  p = [i,p];
  q = [j,q];
end

D_vec = D(r+1,:);
end
