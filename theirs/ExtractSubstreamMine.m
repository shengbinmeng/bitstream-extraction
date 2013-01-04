function ExtractSubstreamMine(DIR, frame_num, pri_vec)
MaxQid = 5;
ParamLine = 6;

max_pri = MaxQid * frame_num;
trc_ori = fopen([DIR, '\\trc\\Orig', int2str(frame_num), '.txt'], 'r');
for i = 1:2
    fgetl(trc_ori);
end
C = textscan(trc_ori, '%s%f%d%d%d%s%s%s');
len = C{2};

data_file = fopen(['data\\', int2str(frame_num), 'extract-data.txt'], 'w');
step = 1;
for k = 1:step:max_pri
    file_name = ['Orig-ext', num2str(k) ,'of', num2str(max_pri)];
    trc_ext = fopen([DIR, '\\trc\\extract-mine\\', file_name, '.txt'], 'w');
    ext_length = sum(len(1:ParamLine));
    ext_length_ql = 0;
    fseek(trc_ori, 0, 'bof');
    for i = 1:2+ParamLine
        tline = fgetl(trc_ori);
        fprintf(trc_ext, [tline, '\r\n']);
    end
    for i = 0:frame_num-1
        for j = 1:2+MaxQid
            tline = fgetl(trc_ori);
            if(pri_vec(i*(2+MaxQid)+j) >= k)
                fprintf(trc_ext, [tline, '\r\n']);
                ext_length = ext_length + len(i*(2+MaxQid)+j+ParamLine);
                if (j>2)
                    ext_length_ql = ext_length_ql + len(i*(2+MaxQid)+j+ParamLine);
                end
            else
                %discard
            end
        end
    end
    fclose(trc_ext);
    fprintf(data_file, '%d %d %d\r\n', k, ext_length, ext_length_ql);
    fid = fopen('Extract.bat', 'w');
    tline = ['..\\bin\\BitStreamExtractorStatic ', DIR, '\\str\\Orig', int2str(frame_num), '.264 ', DIR, '\\str\\extract-mine\\', file_name, '.264 -et ', DIR, '\\trc\\extract-mine\\', file_name, '.txt \r\n'];
    fprintf(fid, tline);
    tline = ['..\\bin\\H264AVCDecoderLibTestStatic ', DIR, '\\str\\extract-mine\\', file_name, '.264 ', DIR, '\\yuv\\extract-mine\\', file_name, '.yuv \r\n'];
    fprintf(fid, tline);
    fclose(fid);
    !Extract.bat
end

fclose(data_file);
fclose(trc_ori);

end