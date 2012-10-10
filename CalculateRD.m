function [psnr_mine psnr_ql psnr_basic] = CalculateRD(DIR)

Width = 352;
Height = 288;
FrameNum = 41;

ext_data = fopen(['result\\', 'extract-data.txt'], 'r');
C = textscan(ext_data, '%d %d');
pri = C{1};
len = C{2};

num = length(pri);
psnr_mine = zeros(num, 1);
psnr_ql = zeros(num, 1);
psnr_basic = zeros(num, 1);
rd_data = fopen(['result\\', 'rd-data.txt'], 'w');

ori_yuv = [DIR, '\\yuv\\Foreman.yuv'];
for k = 1:length(pri)
    file_name = ['Foreman-ext', num2str(k) ,'of', num2str(num)];
    ext_yuv_mine = [DIR, '\\yuv\\extract-mine\\', file_name, '.yuv'];
    ext_yuv_ql = [DIR, '\\yuv\\extract-ql\\', file_name, '.yuv'];
    ext_yuv_basic = [DIR, '\\yuv\\extract-basic\\', file_name, '.yuv'];
    psnr_mine(k) = PSNR(ori_yuv, ext_yuv_mine, Width, Height, FrameNum);
    psnr_ql(k) = PSNR(ori_yuv, ext_yuv_ql, Width, Height, FrameNum);
    psnr_basic(k) = PSNR(ori_yuv, ext_yuv_basic, Width, Height, FrameNum);
    s = sprintf('psnr mine: %.2f, ql: %.2f, basic: %.2f', psnr_mine(k), psnr_ql(k), psnr_basic(k));
    display(s);
    fprintf(rd_data, '%.2f %.2f %.2f %.2f \r\n', len(k), psnr_mine(k), psnr_ql(k), psnr_basic(k));
end

fclose(ext_data);
fclose(rd_data);

end
