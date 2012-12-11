function ErrorVector(DIR, frame_num)
% compute error vector of every packet (run by group)

trace = fopen([DIR, '\\trc\\Orig', int2str(frame_num), '.txt'], 'r');
TemporalLevelPos = 28;
QualityLevelPos = 33;
Width = 352;
Height = 288;
MaxQid = 2;
MaxTid = 3;
ParamLines = 6;

for qlayer = MaxQid:-1:1
    fseek(trace, 0, 'bof');
    file_name = ['Discard_Group_t0q', int2str(qlayer), '_odd'];
    tmp = fopen([DIR, '\\trc\\', file_name, '.txt'], 'w');
    file_name1 = ['Discard_Group_t0q', int2str(qlayer), '_even'];
    tmp1 = fopen([DIR, '\\trc\\', file_name1, '.txt'], 'w');
    % read parameter set
    for i = 1:2+ParamLines
        tline = fgetl(trace);
        fprintf(tmp, [tline, '\r\n']);
        fprintf(tmp1, [tline, '\r\n']);
    end
    even = 1; %discard even group
    flag = 0;
    while (feof(trace) == 0)
        tline = fgetl(trace);
        tid = tline(TemporalLevelPos) - '0';
        qid = tline(QualityLevelPos) - '0';

        if (tid == 0 && qid >= qlayer)
            %discard
            if (even == 0)
                fprintf(tmp1, [tline, '\r\n']);
            else
                fprintf(tmp, [tline, '\r\n']);
            end
            
            flag = flag + 1;
            if (flag > (MaxQid - qlayer))
                even = ~even;
                flag = 0;
            end
        else
            fprintf(tmp, [tline, '\r\n']);
            fprintf(tmp1, [tline, '\r\n']);
        end
    end
    fclose(tmp);
    fclose(tmp1);
    
    % extract and decode
    fid = fopen('Extract.bat', 'w');
    tline = ['..\\bin\\BitStreamExtractorStatic ', DIR, '\\str\\Orig', int2str(frame_num), '.264 ', DIR, '\\str\\', file_name, '.264 -et ', DIR, '\\trc\\', file_name, '.txt \r\n',];
    fprintf(fid, tline);
    tline = ['..\\bin\\H264AVCDecoderLibTestStatic ', DIR, '\\str\\', file_name, '.264 ', DIR, '\\yuv\\', file_name, '.yuv \r\n'];
    fprintf(fid, tline);
    fclose(fid);
    !Extract.bat
    
    if (qlayer == MaxQid) %lowest EL
        ref_name = ['Orig', int2str(frame_num), '-dec'];
    else
        ref_name = ['Discard_Group_t0q', int2str(qlayer+1), '_odd'];
    end
    frames_ref = ReadYUV([DIR, '\\yuv\\', ref_name, '.yuv'], Width, Height, 0, frame_num);
    frames = ReadYUV([DIR, '\\yuv\\', file_name, '.yuv'], Width, Height, 0, frame_num);
    error_vector = zeros(Width*Height, frame_num);
    for frm = 1:frame_num
        error = double(frames(frm).Y) - double(frames_ref(frm).Y);
        mse = mean(error.^2);
        psnr = 10 * log10(255^2 / mse);
        display(psnr);
        error_vector(:,frm) = error;
    end
    save(['data\\', DIR(5:end), int2str(frame_num), '-', file_name, '-err.mat'], 'error_vector');
    

    % extract and decode
    fid = fopen('Extract.bat', 'w');
    tline = ['..\\bin\\BitStreamExtractorStatic ', DIR, '\\str\\Orig', int2str(frame_num), '.264 ', DIR, '\\str\\', file_name1, '.264 -et ', DIR, '\\trc\\', file_name1, '.txt \r\n',];
    fprintf(fid, tline);
    tline = ['..\\bin\\H264AVCDecoderLibTestStatic ', DIR, '\\str\\', file_name1, '.264 ', DIR, '\\yuv\\', file_name1, '.yuv \r\n'];
    fprintf(fid, tline);
    fclose(fid);
    !Extract.bat
    
    if (qlayer == MaxQid) %lowest EL
        ref_name = ['Orig', int2str(frame_num), '-dec'];
    else
        ref_name = ['Discard_Group_t0q', int2str(qlayer+1), '_even'];
    end
    frames_ref = ReadYUV([DIR, '\\yuv\\', ref_name '.yuv'], Width, Height, 0, frame_num);
    frames = ReadYUV([DIR, '\\yuv\\', file_name1, '.yuv'], Width, Height, 0, frame_num);
    error_vector = zeros(Width*Height, frame_num);
    for frm = 1:frame_num
        error = double(frames(frm).Y) - double(frames_ref(frm).Y);
        mse = 1/(Width*Height) * sum(error.^2);
        psnr = 10 * log10(255^2 / mse);
        display(psnr);
        error_vector(:,frm) = error;
    end
    save(['data\\', DIR(5:end), int2str(frame_num), '-', file_name1, '-err.mat'], 'error_vector');
    
    
    for tlayer = 1:MaxTid
        fseek(trace, 0, 'bof');
        file_name = ['Discard_Group_t', int2str(tlayer), 'q', int2str(qlayer)];
        tmp = fopen([DIR, '\\trc\\', file_name, '.txt'], 'w');
        % read parameter set
        for i = 1:2+ParamLines
            tline = fgetl(trace);
            fprintf(tmp, [tline, '\r\n']);
        end
        while (feof(trace) == 0)
            tline = fgetl(trace);
            tid = tline(TemporalLevelPos) - '0';
            qid = tline(QualityLevelPos) - '0';

            if (tid == tlayer && qid >= qlayer)
                %discard
            else
                fprintf(tmp, [tline, '\r\n']);
            end
        end
        fclose(tmp);
        
        % extract and decode
        fid = fopen('Extract.bat', 'w');
        tline = ['..\\bin\\BitStreamExtractorStatic ', DIR, '\\str\\Orig', int2str(frame_num), '.264 ', DIR, '\\str\\', file_name, '.264 -et ', DIR, '\\trc\\', file_name, '.txt \r\n',];
        fprintf(fid, tline);
        tline = ['..\\bin\\H264AVCDecoderLibTestStatic ', DIR, '\\str\\', file_name, '.264 ', DIR, '\\yuv\\', file_name, '.yuv \r\n'];
        fprintf(fid, tline);
        fclose(fid);
        !Extract.bat
        if (qlayer == MaxQid) %highest EL
            ref_name = ['Orig', int2str(frame_num), '-dec'];
        else
            ref_name = ['Discard_Group_t', int2str(tlayer), 'q', int2str(qlayer+1)];
        end
        frames_ref = ReadYUV([DIR, '\\yuv\\', ref_name, '.yuv'], Width, Height, 0, frame_num);
        frames = ReadYUV([DIR, '\\yuv\\', file_name, '.yuv'], Width, Height, 0, frame_num);
        error_vector = zeros(Width*Height, frame_num);
        for frm = 1:frame_num
            error = double(frames(frm).Y) - double(frames_ref(frm).Y);
            mse = 1/(Width*Height) * sum(error.^2);
            psnr = 10 * log10(255^2 / mse);
            display(psnr);
            error_vector(:,frm) = error;
        end
        save(['data\\', DIR(5:end), int2str(frame_num), '-', file_name, '-err.mat'], 'error_vector');
    end

end
fclose(trace);


