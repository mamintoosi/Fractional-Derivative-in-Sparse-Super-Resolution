function [h,hximp,hyimp,hda] = fdf(nu)
% M.Amintoosi
% Based on Ning He paper
if nargin == 0
    nu =0.9;
end
n2u = (nu^2-nu);

hximp = [...
    n2u/12 n2u/3 n2u/12;...
    -nu/5        1     -nu/5;...
    -nu/6   -2/3*nu  -nu/6
    ];
% hximp = hximp/sum(hximp(:))
hyimp = hximp';
hda = [...
    0  0  -nu/6; ...
    0  1  0 ;...
    n2u/2 0 0 ;...
    ];
hdb = flipud(hda);

hd = hximp*hyimp*hda*hdb;
h = hd/sum(hd(:));
