function ExtractSubstreamBasic(DIR)

data = fopen(['result\\', 'extract-data.txt'], 'r');
C = textscan(data, '%d %d');
pri = C{1};
len = C{2};

for k = 1:length(pri)
    file_name = ['Foreman-ext', num2str(k) ,'of', num2str(length(pri))];
    fid = fopen('Extract.bat', 'w');
    tline = ['..\\bin\\BitStreamExtractorStatic ', DIR, '\\str\\Foreman.264 ', DIR, '\\str\\extract-basic\\', file_name, '.264 -e 352x288@30:', num2str(uint16((len(k)/41)*30*8/1000)), '\r\n'];
    fprintf(fid, tline);
    tline = ['..\\bin\\H264AVCDecoderLibTestStatic ', DIR, '\\str\\extract-basic\\', file_name, '.264 ', DIR, '\\yuv\\extract-basic\\', file_name, '.yuv \r\n'];
    fprintf(fid, tline);
    fclose(fid);
    !Extract.bat
end

fclose(data);

end