function ExtractSubstreamBasic(SEQ, frame_num)

DIR = ['..\\', SEQ];
data = fopen(['data\\', int2str(frame_num), 'extract-data.txt'], 'r');
C = textscan(data, '%d %d %d');
pri = C{1};
len = C{2};
len_ql = C{3};
len_ql = double(len_ql);
for k = 1:5:length(pri)
    file_name = [SEQ, '-ext', int2str(k), 'of', int2str(length(pri))];
    fid = fopen('Extract-basic.bat', 'w');
    tline = ['..\\bin\\BitStreamExtractorStatic ', DIR, '\\str\\', SEQ, int2str(frame_num), '.264 ', DIR, '\\str\\extract-basic\\', file_name, '.264 -r ', int2str(uint16((len_ql(k)/len_ql(1)*100))), '%%%% \r\n'];
    fprintf(fid, tline);
    tline = ['..\\bin\\H264AVCDecoderLibTestStatic ', DIR, '\\str\\extract-basic\\', file_name, '.264 ', DIR, '\\yuv\\extract-basic\\', file_name, '.yuv \r\n'];
    fprintf(fid, tline);
    tline = ['..\\bin\\BitStreamExtractorStatic -pt ', DIR, '\\trc\\extract-basic\\', file_name, '.txt ', DIR, '\\str\\extract-basic\\', file_name, '.264 \r\n'];
    fprintf(fid, tline);
    fclose(fid);
    !Extract-basic.bat
end
if k < length(pri)
    k = length(pri);
    file_name = [SEQ, '-ext', int2str(k), 'of', int2str(length(pri))];
    fid = fopen('Extract-basic.bat', 'w');
    tline = ['..\\bin\\BitStreamExtractorStatic ', DIR, '\\str\\', SEQ, int2str(frame_num), '.264 ', DIR, '\\str\\extract-basic\\', file_name, '.264 -r ', int2str(uint16((len_ql(k)/len_ql(1)*100))), '%%%% \r\n'];
    fprintf(fid, tline);
    tline = ['..\\bin\\H264AVCDecoderLibTestStatic ', DIR, '\\str\\extract-basic\\', file_name, '.264 ', DIR, '\\yuv\\extract-basic\\', file_name, '.yuv \r\n'];
    fprintf(fid, tline);
    tline = ['..\\bin\\BitStreamExtractorStatic -pt ', DIR, '\\trc\\extract-basic\\', file_name, '.txt ', DIR, '\\str\\extract-basic\\', file_name, '.264 \r\n'];
    fprintf(fid, tline);
    fclose(fid);
    !Extract-ql.bat
end

fclose(data);

end