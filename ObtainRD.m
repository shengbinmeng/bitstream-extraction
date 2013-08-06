function [psnr_mine psnr_ql psnr_basic] = ObtainRD(DIR, frame_num)

Width = 352;
Height = 288;
FrameRate = 30;
ParamLines = 6;
MaxQid = 2;
BIN_PATH = '..\\bin';

data = load(['data\\', DIR(5:end), int2str(frame_num), '-priority-vector.mat']);
pri_vec = data.priority_vector;

trc_ori = fopen([DIR, '\\trc\\Orig', int2str(frame_num), '.txt'], 'r');
for i = 1:2
    fgetl(trc_ori);
end
C = textscan(trc_ori, '%s%f%d%d%d%s%s%s');
len = C{2};
param_len = sum(len(1:ParamLines));
len = len(ParamLines+1:end);
base_len = sum(len(1:2+MaxQid:end)) + sum(len(2:2+MaxQid:end)) + param_len;
ql_len = 0;
for i = 1:MaxQid
    ql_len = ql_len + sum(len(2+i:2+MaxQid:end));
end

num = 10;
psnr_mine = zeros(num, 1);
psnr_ql = zeros(num, 1);
psnr_basic = zeros(num, 1);
rd_data = fopen(['data\\', DIR(5:end), int2str(frame_num), '-rd-data.txt'], 'w');
ori_yuv = [DIR, '\\yuv\Orig.yuv'];

for k = 1:1:num
    bytes = base_len + (ql_len)*((k-1)/(num-1));
    bitrate = (bytes*8)/1000 / frame_num * FrameRate;
    file_name = ['Orig', int2str(frame_num), '-ext', int2str(bytes) ,'bytes'];
    ExtractSubstreamOfRate(DIR, frame_num, pri_vec, bytes);
    %ExtractSubstreamOfRateGR(DIR, frame_num, bytes);
    fid = fopen('ExtractAndDecode.bat', 'w');
    tline = [BIN_PATH, '\\BitStreamExtractorStatic ', DIR, '\\str\\Orig', int2str(frame_num), '.264 ', DIR, '\\str\\extract-mine\\', file_name, '.264 -et ', DIR, '\\trc\\extract-mine\\', file_name, '.txt \r\n'];
    fprintf(fid, tline);
    tline = [BIN_PATH, '\\H264AVCDecoderLibTestStatic ', DIR, '\\str\\extract-mine\\', file_name, '.264 ', DIR, '\\yuv\\extract-mine\\', file_name, '.yuv \r\n'];
    fprintf(fid, tline);
    
    tline = [BIN_PATH, '\\BitStreamExtractorStatic ', DIR, '\\str\\Orig', int2str(frame_num), '-ql.264 ', DIR, '\\str\\extract-ql\\', file_name, '.264 -r ', int2str(uint16((k-1)/(num-1)*100)), '%%%% -ql\r\n'];
    fprintf(fid, tline);
    tline = [BIN_PATH, '\\H264AVCDecoderLibTestStatic ', DIR, '\\str\\extract-ql\\', file_name, '.264 ', DIR, '\\yuv\\extract-ql\\', file_name, '.yuv \r\n'];
    fprintf(fid, tline);
    
    tline = [BIN_PATH, '\\BitStreamExtractorStatic ', DIR, '\\str\\Orig', int2str(frame_num), '.264 ', DIR, '\\str\\extract-basic\\', file_name, '.264 -r ', int2str(uint16((k-1)/(num-1)*100)), '%%%% \r\n'];
    fprintf(fid, tline);
    tline = [BIN_PATH, '\\H264AVCDecoderLibTestStatic ', DIR, '\\str\\extract-basic\\', file_name, '.264 ', DIR, '\\yuv\\extract-basic\\', file_name, '.yuv \r\n'];
    fprintf(fid, tline);
    fclose(fid);
    !ExtractAndDecode.bat
    
    ext_yuv_mine = [DIR, '\\yuv\\extract-mine\\', file_name, '.yuv'];
    ext_yuv_ql = [DIR, '\\yuv\\extract-ql\\', file_name, '.yuv'];
    ext_yuv_basic = [DIR, '\\yuv\\extract-basic\\', file_name, '.yuv'];
    psnr_mine(k) = PSNR(ori_yuv, ext_yuv_mine, Width, Height, frame_num);
    psnr_ql(k) = PSNR(ori_yuv, ext_yuv_ql, Width, Height, frame_num);
    psnr_basic(k) = PSNR(ori_yuv, ext_yuv_basic, Width, Height, frame_num);
    s = sprintf('%d %.2f psnr mine: %.2f, ql: %.2f, basic: %.2f', k, bitrate, psnr_mine(k), psnr_ql(k), psnr_basic(k));
    display(s);
    fprintf(rd_data, '%.2f %.2f %.2f %.2f \r\n', bitrate, psnr_mine(k), psnr_ql(k), psnr_basic(k));
end
fclose(rd_data);

end
