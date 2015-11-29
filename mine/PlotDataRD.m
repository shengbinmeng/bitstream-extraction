function PlotDataRD(DIR, frame_num)

pos = strfind(DIR, '\');
a = length(pos);
if(a ~= 0) 
    a = pos(a);
end
last_folder = DIR(a+1 : end);

rd_data = fopen(['data\\', last_folder, int2str(frame_num), '-rd-data.txt'], 'r');
C = textscan(rd_data, '%.2f %.2f %.2f %.2f');
bitrate = C{1};
psnr_mine = C{2};
psnr_ql = C{3};
psnr_basic = C{4};

figure;
set(gca,'Fontsize',20);
plot(bitrate, psnr_mine, 'ro-', 'MarkerSize', 12);
xlabel('Bitrate (kbit/s)');
ylabel('PSNR (dB)');
title(last_folder);
hold on
plot(bitrate, psnr_ql, 'b.-', 'MarkerSize', 20);
plot(bitrate, psnr_basic, 'kv-','MarkerSize', 12);
legend('Proposed', 'JSVM QL', 'JSVM Basic', 4);
grid on;
s = sprintf('improvement(ql, basic)\r\nmax: %.2f, %0.2f; min: %.2f, %.2f; mean: %.2f, %.2f\r\n', max(psnr_mine - psnr_ql), max(psnr_mine - psnr_basic), min(psnr_mine - psnr_ql), min(psnr_mine - psnr_basic), mean(psnr_mine - psnr_ql), mean(psnr_mine - psnr_basic));
display(s);
result = fopen(['result\\', last_folder, int2str(frame_num), '-result.txt'], 'a');
fwrite(result, datestr(now, 'yyyy-mm-dd HH:MM:SS  '));
fwrite(result, s);
fseek(rd_data, 0, 'bof');
data_text = fread(rd_data);
fwrite(result, data_text);
fwrite(result, '***************************\r\n');
fclose(result);
fclose(rd_data);
end