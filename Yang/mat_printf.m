function tstr = mat_printf(mahak,methods,x)
% M. Amintoosi
% 

tstr = mahak;
for i=1:numel(x)
    tstr = [tstr sprintf(' %s=%5.3f ',methods{i},x(i))];
end
