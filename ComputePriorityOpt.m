function priority_vector = ComputePriorityOpt(SEQ, frame_num)
%

DIR = ['..\\', SEQ];
Width = 352;
Height = 288;
MaxQid = 2;

% for every SliceData packet(nalu) in the trace file, give it a priority num;
% prefix nalu and base layer nalu can't be discarded, so they have priority
% of Inf.
priority_vector = zeros((2 + MaxQid)*frame_num,1);
priority_vector(1:(2 + MaxQid):end) = Inf;
priority_vector(2:(2 + MaxQid):end) = Inf;

% discard order of packets; another representation of priority
discard_order = [];

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
 --THIS IS WRONG!
%}
%{
gop_packets = ...
[8	6	10	4	14	12	16	2;
 7	5	9	3	13	11	15	1];
%}
gop_num = (frame_num - 1)/8;
packets = zeros(MaxQid, frame_num);
for i = 0:gop_num-1
    packets(:,i*8+2:i*8+9) = gop_packets + i * MaxQid*8 + MaxQid;
end
packets(:,1) = (MaxQid:-1:1)';

trace = fopen([DIR, '\\trc\\', SEQ, int2str(frame_num), '.txt'], 'r');
for i = 1:8
    fgetl(trace);
end

C = textscan(trace, '%s%f%d%d%d%s%s%s', frame_num * (MaxQid+2));
lines = zeros(frame_num*MaxQid, 1);
for i = 0:frame_num-1
    lines(MaxQid*i+1 : MaxQid*i+MaxQid, 1) = 2 + ((MaxQid+2)*i+1 : (MaxQid+2)*i+MaxQid);
end
pkt_length = C{2}(lines, 1);
fclose(trace);


%-------- Initialize the e_full matrix: -------------
% Difference between reconstructional and original Y

orig_file = [DIR, '\\yuv\\', SEQ, '.yuv'];
orig = ReadYUV(orig_file, Width, Height, 0, frame_num);

recon_file = [DIR, '\\yuv\\', SEQ, int2str(frame_num), '_dec.yuv'];
recon = ReadYUV(recon_file, Width, Height, 0, frame_num);
recon_y = zeros(Width*Height, frame_num);
orig_y = zeros(Width*Height, frame_num);
for i = 1:frame_num
    recon_y(:,i) = recon(i).Y;
    orig_y(:,i) = orig(i).Y;
end
e_seq = recon_y - orig_y; %e_full
clear orig recon recon_y orig_y 

mse_seq = mean(e_seq.^2);
psnr_seq = mean(10*log10(255^2./mse_seq));

discard_vector = zeros((2 + MaxQid)*frame_num,1);
pri_data = fopen(['data\\', int2str(frame_num), 'pri-data-opt.txt'], 'w');
trace = fopen([DIR, '\\trc\\', SEQ, int2str(frame_num), '.txt'], 'r');
for j = 1:MaxQid*frame_num
    phi_pkt = zeros(1, frame_num);
    psnr_pkt = zeros(1, frame_num);
    
    for i = 1:frame_num
        if packets(1, i) == 0
            phi_pkt(i) = Inf;
            continue;
        end
        next_discard_vector = discard_vector;
        next_discard_vector((ceil(packets(1, i)/MaxQid)-1)*MaxQid + 2 + packets(1, i)) = 1;
        next_trace = fopen([DIR, '\\trc\\next.txt'], 'w');
        fseek(trace, 0 , 'bof');
        for k = 1:8
            line = fgetl(trace);
            fprintf(next_trace, [line, '\r\n']);
        end
        for k = 1:(MaxQid+2)*frame_num
            line = fgetl(trace);
            if (next_discard_vector(k) == 0)
                fprintf(next_trace, [line, '\r\n']);
            end
        end
        fclose(next_trace);
        
        fid = fopen('ExtractOpt.bat', 'w');
        tline = ['..\\bin\\BitStreamExtractorStatic ', DIR, '\\str\\', SEQ, int2str(frame_num), '.264 ', DIR, '\\str\\next.264 -et ', DIR, '\\trc\\next.txt \r\n'];
        fprintf(fid, tline);
        tline = ['..\\bin\\H264AVCDecoderLibTestStatic ', DIR, '\\str\\next.264 ', DIR, '\\yuv\\next.yuv \r\n'];
        fprintf(fid, tline);
        fclose(fid);
        !ExtractOpt.bat
        
        ori_yuv = ReadYUV(orig_file, Width, Height, 0, frame_num);
        rec_yuv = ReadYUV([DIR, '\\yuv\\next.yuv'], Width, Height, 0, frame_num);
        ori_y = [];
        rec_y = [];
        ori_y = [ori_y ori_yuv.Y];
        rec_y = [rec_y rec_yuv.Y];

        mse = mean((double(rec_y) - double(ori_y)).^2);
        psnr_frames = 10*log10(255^2./mse);
        psnr_frames(psnr_frames == Inf) = 99.99;
        psnr = mean(psnr_frames);
        psnr_pkt(i) = PSNR(orig_file, [DIR, '\\yuv\\next.yuv'], Width, Height, frame_num);
        psnr_pkt(i) = psnr;
        delta_psnr = psnr_seq - psnr_pkt(i);
        delta_r = pkt_length(packets(1,i));
        phi_pkt(i) = abs(delta_psnr)/(delta_r/1000.0);
        
        fprintf(pri_data, '%d %d %f %f %f %d %f \r\n', i, packets(1,i), psnr_seq, psnr_pkt(i), delta_psnr, delta_r, phi_pkt(i));
    end
    
    [min_phi, min_idx] = min(phi_pkt);
    display([min_phi, packets(1, min_idx)]);
    
    discard_order = cat(2, discard_order, packets(1, min_idx));
    priority_vector((ceil(packets(1, min_idx)/MaxQid)-1)*MaxQid + 2 + packets(1, min_idx)) = j;
    
    discard_vector((ceil(packets(1, min_idx)/MaxQid)-1)*MaxQid + 2 + packets(1, min_idx)) = 1;
    psnr_seq = psnr_pkt(min_idx);
    
    packets(1:MaxQid-1, min_idx) = packets(2:MaxQid, min_idx);
    packets(MaxQid, min_idx) = 0;
    
    fprintf(pri_data, '\r\n%d %d %f %f\r\n\r\n', min_idx, packets(1,min_idx), min_phi, psnr_seq);
end

save(['data\\', int2str(frame_num), 'pri_vec-opt.mat'], 'priority_vector', 'discard_order');
fclose(pri_data);
fclose(trace);
end