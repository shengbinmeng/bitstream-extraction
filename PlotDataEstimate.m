function PlotDataEstimate(file_name)
fid = fopen(file_name);
a = fscanf(fid, '%d %d %d %d %d %d %d %d %f %f %f %f\r\n');
error = zeros(255,1);
est_error = zeros(255,1);
diff = zeros(255,1);
for i = 1:255
    error(i) = a((i-1)*12 + 9);
    est_error(i) = a((i-1)*12 + 10);
    diff(i) = a((i-1)*12 + 12);
end

title('Compare of real MSE and estimated MSE (No ref)');
xlabel('Sample No.');
ylabel('MSE');
plot(error,'-r');
hold
plot(est_error,':b');
display(mean(abs(diff)));

error_ref = zeros(256,1);
est_error_ref = zeros(256,1);
diff_ref = zeros(256,1);
for i = (1+256):(256+256)
    error_ref(i-256) = a((i-1)*12 + 9);
    est_error_ref(i-256) = a((i-1)*12 + 10);
    diff_ref(i) = a((i-1)*12 + 12);
end
figure;
title('Compare of real MSE and estimated MSE (with ref)');
xlabel('Sample No.');
ylabel('MSE');
plot(error_ref,'-r');
hold
plot(est_error_ref,':b');
display(mean(abs(diff_ref)));
end