function k_param = KappaParam(DIR, frame_num)

pos = strfind(DIR, '\');
a = length(pos);
if(a ~= 0) 
    a = pos(a);
end
last_folder = DIR(a+1 : end);

data = load(['data\\', last_folder, int2str(frame_num), '-part.mat']);
self_part = data.self_part;
drift_part = data.drift_part;
data = load(['data\\', last_folder, int2str(frame_num), '-actual.mat']);
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

x = (0:0.2:20)*10e4;
y = (0:0.2:20)*10e4;
[X Y] = meshgrid(x, y);
z = X + Y + 2*p*X.*Y;
surf(x, y, z);
hold on
scatter3(xdata(:,1), xdata(:,2), ydata);
hold off

k_param = p;
display(p);
end