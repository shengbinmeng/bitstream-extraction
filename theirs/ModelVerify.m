function ModelVerify(DIR, frame_num)

Width = 352;
Height = 288;
SampleNum = 1;
ParamLines = 6;
MaxQid = 2;
BIN_PATH = '..\\bin';

trace = fopen([DIR, '\\trc\\Orig', int2str(frame_num), '.txt'], 'r');
select_map = zeros(1, frame_num);
decode_to_display = [1 9 5 3 2 4 7 6 8];
for k = 1:SampleNum
    for i = 1:frame_num
        rand_id = ceil((MaxQid+1)*rand());
        select_map(i) = rand_id;
    end
    fseek(trace, 0, 'bof');
    file_name = ['Discard-Rand-Sample', int2str(k)];
    tmp = fopen([DIR, '\\trc\\', file_name, '.txt'], 'w');
    for i = 1:2+ParamLines
        tline = fgetl(trace);
        fprintf(tmp, [tline, '\r\n']);
    end
    for i = 1:frame_num
        for j=1:2
            % base layer
            tline = fgetl(trace);
            fprintf(tmp, [tline, '\r\n']);
        end
        if (i<=9)
            frm = decode_to_display(i);
        else 
            skip_gop = ceil((i-1)/8) - 1;
            frm = decode_to_display(i-8*skip_gop) + 8*skip_gop;
        end
        map_id = select_map(frm);
        for j=1:map_id-1
            tline = fgetl(trace);
            fprintf(tmp, [tline, '\r\n']);
        end
        for j=map_id:5
            % discard
            tline = fgetl(trace);
        end
    end
    fclose(tmp);

    d_estimate = EstimateDistortion(select_map, frame_num);
    % extract and decode
    fid = fopen('Extract.bat', 'w');
    tline = [BIN_PATH, '\\BitStreamExtractorStatic ', DIR, '\\str\\Orig', int2str(frame_num), '.264 ', DIR, '\\str\\', file_name, '.264 -et ', DIR, '\\trc\\', file_name, '.txt \r\n',];
    fprintf(fid, tline);
    tline = [BIN_PATH, '\\H264AVCDecoderLibTestStatic ', DIR, '\\str\\', file_name, '.264 ', DIR, '\\yuv\\', file_name, '.yuv \r\n'];
    fprintf(fid, tline);
    fclose(fid);
    !Extract.bat

    ref_name = ['Orig', int2str(frame_num), '-dec'];
    frames_ref = ReadYUV([DIR, '\\yuv\\', ref_name, '.yuv'], Width, Height, 0, frame_num);
    frames = ReadYUV([DIR, '\\yuv\\', file_name, '.yuv'], Width, Height, 0, frame_num);
    d_actual = zeros(1, frame_num);
    for frm = 1:frame_num
        error = double(frames(frm).Y) - double(frames_ref(frm).Y);
        sse = sum(error.^2);
        d_actual(frm) = sse/(Width*Height);
    end
    
    figure;
    title('Compare of real MSE and estimated MSE (No ref)');
    xlabel('Sample No.');
    ylabel('MSE');
    plot(d_actual,'-r');
    hold on
    plot(d_estimate,':b');
    hold off
    s = sprintf('%f / %f = %f', mean(abs(d_estimate-d_actual)), mean(d_actual), mean(abs(d_estimate-d_actual))/mean(d_actual));
    display(s);
end
    d_actual = d_actual*(Width*Height);
    save('data\\actual.mat', 'd_actual');
end