function PlotDataEstimate(file_name)
fid = fopen(file_name);
a = textscan(fid, '%d %d %d %d %d %d %d %d %f %f %f %f\r\n');
error = a{9};
est_error = a{10};
diff = a{12};

title('Compare of real MSE and estimated MSE (No ref)');
xlabel('Sample No.');
ylabel('MSE');
plot(error,'-r');
hold
plot(est_error,':b');
display(mean(abs(diff)));

end