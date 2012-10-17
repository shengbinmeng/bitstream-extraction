function PacketErrorVector(SEQ, frame_num)
% compute error vector of every packet (run by group)

DIR = ['..\\', SEQ];
trace = fopen([DIR, '\\trc\\', SEQ, '.txt'], 'r');
TemporalLevelPos = 28;
QualityLevelPos = 33;
Width = 352;
Height = 288;
MaxQid = 2;
MaxTid = 3;
gop_num = frame_num / 8;
pkt_err_all = int16(zeros(frame_num * MaxQid, Width*Height, 15));
for qlayer = MaxQid:-1:1
    fseek(trace, 0, 'bof');
    file_name = ['Discard_Group_t0q', int2str(qlayer), '_odd'];
    tmp = fopen([DIR, '\\trc\\', file_name, '.txt'], 'w');
    file_name1 = ['Discard_Group_t0q', int2str(qlayer), '_even'];
    tmp1 = fopen([DIR, '\\trc\\', file_name1, '.txt'], 'w');
    % read parameter set
    for i = 1:10
        tline = fgetl(trace);
        fprintf(tmp, [tline, '\r\n']);
        fprintf(tmp1, [tline, '\r\n']);
    end
    % frame 0
    for i = 1:4
        tline = fgetl(trace);
        fprintf(tmp, [tline, '\r\n']);
        fprintf(tmp1, [tline, '\r\n']);
    end
    even = 0;
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
    tline = ['..\\bin\\BitStreamExtractorStatic ', DIR, '\\str\\', SEQ, '.264 ', DIR, '\\str\\', file_name, '.264 -et ', DIR, '\\trc\\', file_name, '.txt \r\n',];
    fprintf(fid, tline);
    tline = ['..\\bin\\H264AVCDecoderLibTestStatic ', DIR, '\\str\\', file_name, '.264 ', DIR, '\\yuv\\', file_name, '.yuv \r\n'];
    fprintf(fid, tline);
    fclose(fid);
    !Extract.bat
    
    if (qlayer == MaxQid) %lowest EL
        ref_name = [SEQ ,'_dec'];
    else
        ref_name = ['Discard_Group_t0q', int2str(qlayer+1), '_odd'];
    end
    frames_ref = ReadYUV([DIR, '\\yuv\\', ref_name '.yuv'], Width, Height, 1, frame_num);
    frames = ReadYUV([DIR, '\\yuv\\', file_name, '.yuv'], Width, Height, 1, frame_num);
    error_vector = zeros(Width*Height, frame_num);
    for frm = 1:frame_num
        error = int16(frames(frm).Y) - int16(frames_ref(frm).Y);
        mse = 1/(Width*Height) * sum(error.^2);
        psnr = 10 * log10(255^2 / mse);
        display(psnr);
        error_vector(:,frm) = error;
    end
    for gop_idx = 1:2:gop_num
        offset = (gop_idx-1)*8;
        frames = length(error_vector(1,:)) - offset;
        if (frames > 15)
            frames = 15;
        end
        pkt_err_all(0 + qlayer + (gop_idx-1)*8*MaxQid, :, 1:frames) = error_vector(:,(offset+1):(offset+frames));
    end
    save(['data\\', file_name, '-err.mat'], 'error_vector');
    

    % extract and decode
    fid = fopen('Extract.bat', 'w');
    tline = ['..\\bin\\BitStreamExtractorStatic ', DIR, '\\str\\', SEQ, '.264 ', DIR, '\\str\\', file_name1, '.264 -et ', DIR, '\\trc\\', file_name1, '.txt \r\n',];
    fprintf(fid, tline);
    tline = ['..\\bin\\H264AVCDecoderLibTestStatic ', DIR, '\\str\\', file_name1, '.264 ', DIR, '\\yuv\\', file_name1, '.yuv \r\n'];
    fprintf(fid, tline);
    fclose(fid);
    !Extract.bat
    
    if (qlayer == MaxQid) %lowest EL
        ref_name = [SEQ ,'_dec'];
    else
        ref_name = ['Discard_Group_t0q', int2str(qlayer+1), '_even'];
    end
    frames_ref = ReadYUV([DIR, '\\yuv\\', ref_name '.yuv'], Width, Height, 1, frame_num);
    frames = ReadYUV([DIR, '\\yuv\\', file_name1, '.yuv'], Width, Height, 1, frame_num);
    error_vector = zeros(Width*Height, frame_num);
    for frm = 1:frame_num
        error = int16(frames(frm).Y) - int16(frames_ref(frm).Y);
        mse = 1/(Width*Height) * sum(error.^2);
        psnr = 10 * log10(255^2 / mse);
        display(psnr);
        error_vector(:,frm) = error;
    end
    for gop_idx = 2:2:gop_num
        offset = (gop_idx-1)*8;
        frames = length(error_vector(1,:)) - offset;
        if (frames > 15)
            frames = 15;
        end
        pkt_err_all(0 + qlayer + (gop_idx-1)*8*MaxQid, :, 1:frames) = error_vector(:,(offset+1):(offset+frames));
    end
    save(['data\\', file_name1, '-err.mat'], 'error_vector');
    
    
    for tlayer = 1:MaxTid
        fseek(trace, 0, 'bof');
        file_name = ['Discard_Group_t', int2str(tlayer), 'q', int2str(qlayer)];
        tmp = fopen([DIR, '\\trc\\', file_name, '.txt'], 'w');
        % read parameter set
        for i = 1:10
            tline = fgetl(trace);
            fprintf(tmp, [tline, '\r\n']);
        end
        % frame 0
        for i = 1:4
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
        tline = ['..\\bin\\BitStreamExtractorStatic ', DIR, '\\str\\', SEQ, '.264 ', DIR, '\\str\\', file_name, '.264 -et ', DIR, '\\trc\\', file_name, '.txt \r\n',];
        fprintf(fid, tline);
        tline = ['..\\bin\\H264AVCDecoderLibTestStatic ', DIR, '\\str\\', file_name, '.264 ', DIR, '\\yuv\\', file_name, '.yuv \r\n'];
        fprintf(fid, tline);
        fclose(fid);
        !Extract.bat
        if (qlayer == MaxQid) %highest EL
            ref_name = [SEQ ,'_dec'];
        else
            ref_name = ['Discard_Group_t', int2str(tlayer), 'q', int2str(qlayer+1)];
        end
        frames_ref = ReadYUV([DIR, '\\yuv\\', ref_name '.yuv'], Width, Height, 1, frame_num);
        frames = ReadYUV([DIR, '\\yuv\\', file_name, '.yuv'], Width, Height, 1, frame_num);
        error_vector = zeros(Width*Height, frame_num);
        for frm = 1:frame_num
            error = int16(frames(frm).Y) - int16(frames_ref(frm).Y);
            mse = 1/(Width*Height) * sum(error.^2);
            psnr = 10 * log10(255^2 / mse);
            display(psnr);
            error_vector(:,frm) = error;
        end
        if (tlayer == 1)
            frame_idx = 4;
            for gop_idx = 1:gop_num
                offset = (gop_idx-1)*8;
                pkt_err_all(MaxQid*1 + qlayer + (gop_idx-1)*8*MaxQid, :, frame_idx-3:frame_idx+3) = error_vector(:,(offset+frame_idx-3):(offset+frame_idx+3));
            end
        elseif (tlayer == 2)
            frame_idx = 2;
            for gop_idx = 1:gop_num
                offset = (gop_idx-1)*8;
                pkt_err_all(MaxQid*2 + qlayer + (gop_idx-1)*8*MaxQid, :, frame_idx-1:frame_idx+1) = error_vector(:,(offset+frame_idx-1):(offset+frame_idx+1));
            end
            frame_idx = 5;
            for gop_idx = 1:gop_num
                offset = (gop_idx-1)*8;
                pkt_err_all(MaxQid*3 + qlayer + (gop_idx-1)*8*MaxQid, :, frame_idx-1:frame_idx+1) = error_vector(:,(offset+frame_idx-1):(offset+frame_idx+1));
            end
        elseif (tlayer == 3)
            for frame_idx = 1:2:7
                for gop_idx = 1:gop_num
                    offset = (gop_idx-1)*8;
                    pkt_err_all(MaxQid*(3+ceil(frame_idx/2)) + qlayer + (gop_idx-1)*8*MaxQid, :, frame_idx-0:frame_idx+0) = error_vector(:,(offset+frame_idx-0):(offset+frame_idx+0));
                end
            end
        end  
        save(['data\\', file_name, '-err.mat'], 'error_vector');
    end
end

save(['data\\', 'pkt_err_all.mat'], 'pkt_err_all');
fclose(trace);
end

