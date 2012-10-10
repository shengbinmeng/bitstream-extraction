function [discard_order, priority_vector] = ComputePriority(SEQ, frame_start, frame_num)
%

DIR = ['..\\', SEQ];
%frame_start = 1;
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
gop_packets(:, 6) = MaxQid*4:-1:MaxQid*3 + 1;
gop_packets(:, 1) = MaxQid*5:-1:MaxQid*4 + 1;
gop_packets(:, 3) = MaxQid*6:-1:MaxQid*5 + 1;
gop_packets(:, 5) = MaxQid*7:-1:MaxQid*6 + 1;
gop_packets(:, 7) = MaxQid*8:-1:MaxQid*7 + 1;
%{
gop_packets = ...
[10	6	12	4	14	8	16	2;
 9	5	11	3	13	7	15	1];
%}
gop_num = (frame_num - 0)/8;
packets = zeros(MaxQid, gop_num*8);
for i = 0:gop_num-1
    packets(:,i*8+1:i*8+8) = gop_packets + i * MaxQid*8;
end

trace = fopen([DIR, '\\trc\\', SEQ, '.txt'], 'r');
for i = 1:10+frame_start*(2+MaxQid)
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
orig = ReadYUV(orig_file, Width, Height, frame_start, frame_num);

recon_file = [DIR, '\\yuv\\', SEQ, '_dec.yuv'];
recon = ReadYUV(recon_file, Width, Height, frame_start, frame_num);
recon_y = zeros(Width*Height, frame_num);
orig_y = zeros(Width*Height, frame_num);
for i = 1:frame_num
    recon_y(:,i) = recon(i).Y;
    orig_y(:,i) = orig(i).Y;
end
e_seq = recon_y - orig_y; %e_full
clear orig recon recon_y orig_y 

mse_seq = mean(mean(e_seq.^2));
psnr_seq = 10*log10(255^2./mse_seq);
%{
e_seq2 = reshape(e_seq, Width*Height*frame_num, 1);
mse_seq2 = mean(e_seq2.^2);
psnr_seq2 = 10*log10(255^2./mse_seq2);
%}

e_pkt = zeros(Width * Height, frame_num);
for j = 1:MaxQid*frame_num
    phi_pkt = zeros(1, frame_num);
    mse_pkt = zeros(1, frame_num);
    psnr_pkt = zeros(1, frame_num);
    
    for i = 1:frame_num
        if packets(1, i) == 0
            phi_pkt(i) = Inf;
            continue;
        end
        
        pkt_err_all = AllPacketError();
        packet_error =  pkt_err_all(packets(1,i),:,:);
        gop_idx = ceil(i / 8);
        offset = (gop_idx-1)*8;
        affect_frames = 15;
        if (offset + affect_frames > frame_num)
            affect_frames = frame_num - offset;
        end
        e_pkt(:,offset+1:offset+affect_frames) = packet_error(:,1:affect_frames);
        mse_pkt(i) = mean(mean((e_pkt + e_seq).^2));
        psnr_pkt(i) = 10*log10(255^2./mse_pkt(i));
        phi_pkt(i) = (psnr_seq - psnr_pkt(i))/pkt_length(packets(1, i));
    end
    
    [min_psnr, min_idx] = min(phi_pkt);
    display(packets(1, min_idx));
    
    discard_order = cat(2, discard_order, packets(1, min_idx));
    priority_vector((ceil(packets(1, min_idx)/MaxQid)-1)*MaxQid + 2 + packets(1, min_idx)) = j;
    
    packet_error =  PacketError(packets(1,min_idx), 2);
    gop_idx = ceil(min_idx / 8);
    offset = (gop_idx-1)*8;
    affect_frames = 15;
    if (offset + affect_frames > frame_num)
        affect_frames = frame_num - offset;
    end
    e_pkt(:,offset+1:offset+affect_frames) = packet_error(:,1:affect_frames);
    e_seq = e_seq + e_pkt;
    mse_seq = mean(mean(e_seq.^2));
    psnr_seq = 10*log10(255^2./mse_seq);
    
    packets(1:MaxQid-1, min_idx) = packets(2:MaxQid, min_idx);
    packets(MaxQid, min_idx) = 0;
end

end