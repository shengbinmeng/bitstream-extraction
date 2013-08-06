function k_param = KappaParam(frame_num)

data = load('data\\part.mat');
self_part = data.self_part;
drift_part = data.drift_part;
data = load('data\\actual.mat');
d_actual = data.d_actual;
len = length(self_part);
xdata = zeros(len, 2);
ydata = zeros(len, 1);


xdata(:,1) = self_part(:);
xdata(:,2) = drift_part(:);
ydata(:) = d_actual;
fun = @(p,xdata) xdata(:,1)+xdata(:,2)+2*p*(xdata(:,1).*xdata(:,2)).^0.5;
options = optimset('LargeScale', 'off');
[p,resnorm,residual,exitflag,output] = lsqcurvefit(fun, 0, xdata, ydata, 0, 1, options);
%{
x = (0:0.2:20)*10e4;
y = (0:0.2:20)*10e4;
[X Y] = meshgrid(x, y);
z = X + Y + 2*p*X.*Y;
%figure;
surf(x, y, z);
hold on
scatter3(xdata(:,1), xdata(:,2), ydata);
hold off
%}
k_param = p;
display(p);
end