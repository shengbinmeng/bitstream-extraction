function ModelVerifyRand(DIR, frame_num)
% extract randly the possible combinations of enhancement packet numbers in
% each frame in one GOP

trace = fopen([DIR, '\\trc\\Orig', int2str(frame_num), '.txt'], 'r');
MaxQid = 2;
Width = 352;
Height = 288;
ParamLines = 6;
SampleNum = 1;
BIN_PATH = '..\\bin';
has_ref = 0;

gop_packets = zeros(MaxQid, 8);
gop_packets(:, 8) = MaxQid:-1:1;
gop_packets(:, 4) = MaxQid*2:-1:MaxQid*1 + 1;
gop_packets(:, 2) = MaxQid*3:-1:MaxQid*2 + 1;
gop_packets(:, 1) = MaxQid*4:-1:MaxQid*3 + 1;
gop_packets(:, 3) = MaxQid*5:-1:MaxQid*4 + 1;
gop_packets(:, 6) = MaxQid*6:-1:MaxQid*5 + 1;
gop_packets(:, 5) = MaxQid*7:-1:MaxQid*6 + 1;
gop_packets(:, 7) = MaxQid*8:-1:MaxQid*7 + 1;
%{
gop_packets = ...
[10	6	12	4	14	8	16	2;
 9	5	11	3	13	7	15	1];
%}
gop_num = (frame_num - 1)/8;
packets = zeros(MaxQid, frame_num);
for i = 0:gop_num-1
    packets(:,i*8+2:i*8+9) = gop_packets + i * MaxQid*8 + MaxQid;
end
packets(:,1) = (MaxQid:-1:1)';

select_map = zeros(1, frame_num);
decode_to_display = [1 9 5 3 2 4 7 6 8];
for k = 1:SampleNum
    for i = 1:frame_num
        rand_id = ceil((MaxQid+1)*rand()); % 1~(MaxQid+1)
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
        for j=map_id:MaxQid
            % discard
            fgetl(trace);
        end
    end
    fclose(tmp);

    recon_file = [DIR, '\\yuv\\Orig', int2str(frame_num), '-dec.yuv'];
    recon = ReadYUV(recon_file, Width, Height, 0, frame_num);
    orig_file = [DIR, '\\yuv\\Orig.yuv'];
    orig = ReadYUV(orig_file, Width, Height, 0, frame_num);
    recon_y = zeros(Width*Height, frame_num);
    orig_y = zeros(Width*Height, frame_num);
    for i = 1:frame_num
        recon_y(:,i) = recon(i).Y;
        orig_y(:,i) = orig(i).Y;
    end
    if (has_ref == 1)
        e_seq = recon_y - orig_y;
    else 
        e_seq = recon_y - recon_y;
    end
    clear recon recon_y orig orig_y

    for i = 1:frame_num
        map_id = select_map(i);
        for j = map_id:MaxQid
            packet_error =  PacketError(DIR, frame_num, packets(j,i),2);
            if (i == 1)
                %first frame
                affect_frames = 8;
                offset = 0;
            else
                gop_idx = ceil((i-1) / 8);
                offset = (gop_idx-1)*8 + 1;
                affect_frames = 15;
                if (offset + affect_frames > frame_num)
                    affect_frames = frame_num - offset;
                end
            end

            e_seq(:,offset+1:offset+affect_frames) = e_seq(:,offset+1:offset+affect_frames) + packet_error(:,1:affect_frames);
        end
    end
    
    d_estimate = sum(e_seq.^2)/(Width*Height);
    
    % extract and decode
    fid = fopen('ExtractRand.bat', 'w');
    tline = [BIN_PATH, '\\BitStreamExtractorStatic ', DIR, '\\str\\Orig', int2str(frame_num), '.264 ', DIR, '\\str\\', file_name, '.264 -et ', DIR, '\\trc\\', file_name, '.txt \r\n',];
    fprintf(fid, tline);
    tline = [BIN_PATH, '\\H264AVCDecoderLibTestStatic ', DIR, '\\str\\', file_name, '.264 ', DIR, '\\yuv\\', file_name, '.yuv \r\n'];
    fprintf(fid, tline);
    fclose(fid);
    !ExtractRand.bat

    if (has_ref == 1)
        ref_name = 'Orig';
    else
        ref_name = ['Orig', int2str(frame_num), '-dec'];
    end
    frames_ref = ReadYUV([DIR, '\\yuv\\', ref_name, '.yuv'], Width, Height, 0, frame_num);
    frames = ReadYUV([DIR, '\\yuv\\', file_name, '.yuv'], Width, Height, 0, frame_num);
    d_actual = zeros(1, frame_num);
    for frm = 1:frame_num
        error = double(frames(frm).Y) - double(frames_ref(frm).Y);
        sse = sum(error.^2);
        d_actual(frm) = sse/(Width*Height);
    end
    
    figure;
    title('Compare of real MSE and estimated MSE');
    xlabel('Frame Index');
    ylabel('MSE');
    plot(d_actual,'-r');
    hold on
    plot(d_estimate,':b');
    hold off
    s = sprintf('average estimate error: %f', mean(abs(d_estimate-d_actual)/d_actual));
    display(s);
end
end