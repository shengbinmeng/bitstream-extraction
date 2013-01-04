function PlotDataRD(frame_num)

rd_data = fopen(['data\\', int2str(frame_num), 'rd-data.txt'], 'r');
C = textscan(rd_data, '%.2f %.2f %.2f %.2f');
length = C{1};
psnr_mine = C{2};
psnr_ql = C{3};
psnr_basic = C{4};

figure;
set(gca,'Fontsize',20);
plot(length, psnr_mine, 'rx-');
xlabel('Length / Bytes');
ylabel('PSNR / dB');
hold on
plot(length, psnr_ql, 'bx-');
plot(length, psnr_basic, 'kx-');
legend('Proposed', 'JSVM with QL', 'JSVM no QL', 4);
grid on;
s = sprintf('improvement(ql, basic) \r\n max: %.2f, %0.2f; min: %.2f, %.2f; mean: %.2f, %.2f', max(psnr_mine - psnr_ql), max(psnr_mine - psnr_basic), min(psnr_mine - psnr_ql), min(psnr_mine - psnr_basic), mean(psnr_mine - psnr_ql), mean(psnr_mine - psnr_basic));
display(s);
fclose(rd_data);
end