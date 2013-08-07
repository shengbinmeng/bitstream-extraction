function drift_params = DriftParams(DIR, frame_num)

pos = strfind(DIR, '\');
a = length(pos);
if(a ~= 0) 
    a = pos(a);
end
last_folder = DIR(a+1 : end);

data = load(['data\\', last_folder, int2str(frame_num), '-drift-data.mat']);
drift_data = data.drift_data;
sample_num = 20;
if (sample_num>size(drift_data,3))
    sample_num = size(drift_data,3);
end;
data = drift_data(:,:,1:sample_num);
xdata = zeros(size(data,3), 2);
ydata = zeros(size(data,3), 1);
param = zeros(5, frame_num);
for i =1:frame_num
    if (mod(i, 8) == 1)
        continue;
    end
    xdata(:,1) = data(2,i,:);
    xdata(:,2) = data(3,i,:);
    ydata(:) = data(1,i,:);
    fun = @(p,xdata) p(1)*xdata(:,1) + p(2)*xdata(:,2) + p(3)*xdata(:,1).^2 + p(4)*xdata(:,2).^2 + p(5)*xdata(:,1).*xdata(:,2);
    options = optimset('LargeScale', 'off');
    [p,resnorm,residual,exitflag,output] = lsqcurvefit(fun, [-0.3 1.2 1 1 1], xdata, ydata, [], [], options);
    param(:,i) = p';
    
    x = (0:0.2:20)*10e4;
    y = (0:0.2:20)*10e4;
    [X Y] = meshgrid(x, y);
    z = p(1)*X + p(2)*Y + p(3)*X.^2 + p(4)*Y.^2 + p(5)*X.*Y;
    surf(x, y, z);
    hold on
    scatter3(xdata(:,1), xdata(:,2), ydata);
    hold off
end
drift_params = param;
save(['data\\', last_folder, int2str(frame_num), '-drift-params.mat'], 'drift_params');
end