function [psnr_mine psnr_ql psnr_basic] = CalculateRD(DIR, frame_num)

Width = 352;
Height = 288;

ext_data = fopen(['data\\', int2str(frame_num), 'extract-data.txt'], 'r');
C = textscan(ext_data, '%d %d %d');
pri = C{1};
len = C{2};

num = length(pri);
psnr_mine = zeros(num, 1);
psnr_ql = zeros(num, 1);
psnr_basic = zeros(num, 1);
rd_data = fopen(['data\\', int2str(frame_num), 'rd-data.txt'], 'w');

ori_yuv = [DIR, '\\yuv\Orig.yuv'];
step = 2;
for k = 1:step:length(pri)
    file_name = ['Orig-ext', int2str(k) ,'of', int2str(num)];
    ext_yuv_mine = [DIR, '\\yuv\\extract-mine\\', file_name, '.yuv'];
    ext_yuv_ql = [DIR, '\\yuv\\extract-ql\\', file_name, '.yuv'];
    ext_yuv_basic = [DIR, '\\yuv\\extract-basic\\', file_name, '.yuv'];
    psnr_mine(k) = PSNR(ori_yuv, ext_yuv_mine, Width, Height, frame_num);
    psnr_ql(k) = PSNR(ori_yuv, ext_yuv_ql, Width, Height, frame_num);
    psnr_basic(k) = PSNR(ori_yuv, ext_yuv_basic, Width, Height, frame_num);
    s = sprintf('%d psnr mine: %.2f, ql: %.2f, basic: %.2f', k,  psnr_mine(k), psnr_ql(k), psnr_basic(k));
    display(s);
    fprintf(rd_data, '%.2f %.2f %.2f %.2f \r\n', len(k), psnr_mine(k), psnr_ql(k), psnr_basic(k));
end
if k < length(pri)
    k = length(pri);
    file_name = ['Orig-ext', int2str(k) ,'of', int2str(num)];
    ext_yuv_mine = [DIR, '\\yuv\\extract-mine\\', file_name, '.yuv'];
    ext_yuv_ql = [DIR, '\\yuv\\extract-ql\\', file_name, '.yuv'];
    ext_yuv_basic = [DIR, '\\yuv\\extract-basic\\', file_name, '.yuv'];
    psnr_mine(k) = PSNR(ori_yuv, ext_yuv_mine, Width, Height, frame_num);
    psnr_ql(k) = PSNR(ori_yuv, ext_yuv_ql, Width, Height, frame_num);
    psnr_basic(k) = PSNR(ori_yuv, ext_yuv_basic, Width, Height, frame_num);
    s = sprintf('%d psnr mine: %.2f, ql: %.2f, basic: %.2f', k,  psnr_mine(k), psnr_ql(k), psnr_basic(k));
    display(s);
    fprintf(rd_data, '%.2f %.2f %.2f %.2f \r\n', len(k), psnr_mine(k), psnr_ql(k), psnr_basic(k));
end

fclose(ext_data);
fclose(rd_data);

end
