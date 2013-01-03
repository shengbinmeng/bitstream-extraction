function ExtractSubstreamOfRateGR(DIR, frame_num, target_bytes)


Width = 352;
Height = 288;
MaxQid = 2;
ParamLines = 6;

trc_ori = fopen([DIR, '\\trc\\Orig', int2str(frame_num), '.txt'], 'r');
for i = 1:2
    fgetl(trc_ori);
end
C = textscan(trc_ori, '%s%f%d%d%d%s%s%s');
len = C{2};
task_size = sum(len) - target_bytes;
param_len = sum(len(1:ParamLines));
len = len(ParamLines+1:end);

basic_len = param_len + sum(len(1:(2 + MaxQid):end)) + sum(len(2:(2 + MaxQid):end));
enhence_len = target_bytes - basic_len;

lines = zeros(frame_num*MaxQid, 1);
for i = 0:frame_num-1
    lines(MaxQid*i+1 : MaxQid*i+MaxQid, 1) = 2 + ((MaxQid+2)*i+1 : (MaxQid+2)*i+MaxQid);
end
global pkt_length;
pkt_length = len(lines, 1);

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
e_seq = recon_y - orig_y;
clear recon recon_y orig orig_y

mse_seq = mean(e_seq.^2);
psnr_seq = 10*log10(255^2./mse_seq);
psnr_seq(psnr_seq > 99) = 99;
psnr_seq = mean(psnr_seq);
discarded_size = 0;
while (discarded_size < task_size)
    if (sum(packets(1,:)) == 0)
        % all packets discarded
        break;
    end
    
    % oen packet
    phi_pkt = zeros(1, frame_num);
    for i = 1:frame_num
        if packets(1, i) == 0
            phi_pkt(i) = Inf;
            continue;
        end
        
        packet_error =  PacketError(DIR, frame_num, packets(1,i),2);
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
        
        e_pkt = zeros(Width * Height, frame_num);
        e_pkt(:,offset+1:offset+affect_frames) = packet_error(:,1:affect_frames);
        mse_pkt = mean((e_pkt + e_seq).^2);
        % use psnr
        psnr_pkt = 10*log10(255^2./mse_pkt);
        psnr_pkt(psnr_pkt > 99) = 99;
        psnr_pkt = mean(psnr_pkt);
        
        delta_d = psnr_pkt - psnr_seq;
        delta_r = pkt_length(packets(1,i));
        phi_pkt(i) = abs(delta_d)/(delta_r/1000);
        
        %fprintf(pri_data, '%d %d %f %f %f %d %f \r\n', i, packets(1,i), mse_seq, mse_pkt, delta_d, delta_r, phi_pkt(i));
    end
    
    % two packet group
    min_phi_pkts = Inf;
    min_idx1 = 0;
    min_idx2 = 0;
    for i = 1:frame_num
        if (packets(1,i)==0)
            continue;
        else
            pkt1 = packets(1,i);
            packets_copy = packets;
            packets_copy(1:MaxQid-1, i) = packets_copy(2:MaxQid, i);
            packets_copy(MaxQid, i) = 0;
            for j=i:frame_num
                if(packets_copy(1,j)==0)
                    continue;
                else
                    pkt2 = packets_copy(1,j);
                    
                    e_pkts = zeros(Width * Height, frame_num);
                    
                    packet_error =  PacketError(DIR, frame_num, pkt1,2);
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
                    e_pkts(:,offset+1:offset+affect_frames) = e_pkts(:,offset+1:offset+affect_frames) + packet_error(:,1:affect_frames);
                    
                    packet_error =  PacketError(DIR, frame_num, pkt2, 2);
                    if (j == 1)
                        %first frame
                        affect_frames = 8;
                        offset = 0;
                    else
                        gop_idx = ceil((j-1) / 8);
                        offset = (gop_idx-1)*8 + 1;
                        affect_frames = 15;
                        if (offset + affect_frames > frame_num)
                            affect_frames = frame_num - offset;
                        end
                    end
                    e_pkts(:,offset+1:offset+affect_frames) = e_pkts(:,offset+1:offset+affect_frames) + packet_error(:,1:affect_frames);
                    
                    mse_pkts = mean((e_pkts + e_seq).^2);
                    % use psnr
                    psnr_pkts = 10*log10(255^2./mse_pkts);
                    psnr_pkts(psnr_pkts > 99) = 99;
                    psnr_pkts = mean(psnr_pkts);

                    delta_d = psnr_pkts - psnr_seq;
                    delta_r = pkt_length(pkt1) + pkt_length(pkt2);
                    phi_pkts = abs(delta_d)/(delta_r/1000);
                    display([i, j, phi_pkts]);
                    if (phi_pkts < min_phi_pkts)
                        min_phi_pkts = phi_pkts;
                        min_idx1 = i;
                        min_idx2 = j;
                    end
                end
            end
        end
    end
    
    [min_phi_pkt, min_idx] = min(phi_pkt);
    display([min_phi_pkt, min_idx, packets(1, min_idx)]);
    display([min_phi_pkts, min_idx1, min_idx2]);
    
    if (min_phi_pkt < min_phi_pkts)
        packet_error =  PacketError(DIR, frame_num, packets(1,min_idx), 2);
        if (min_idx == 1)
            affect_frames = 8;
            offset = 0;
        else
            gop_idx = ceil((min_idx-1) / 8);
            offset = (gop_idx-1)*8 + 1;
            affect_frames = 15;
            if (offset + affect_frames > frame_num)
                affect_frames = frame_num - offset;
            end
        end
        e_pkt = zeros(Width * Height, frame_num);
        e_pkt(:,offset+1:offset+affect_frames) = packet_error(:,1:affect_frames);
        e_seq = e_seq + e_pkt;
        mse_seq = mean(e_seq.^2);
        psnr_seq = 10*log10(255^2./mse_seq);
        psnr_seq(psnr_seq > 99) = 99;
        psnr_seq = mean(psnr_seq);
        
        discarded_size = discarded_size + pkt_length(packets(1,min_idx));
        packets(1:MaxQid-1, min_idx) = packets(2:MaxQid, min_idx);
        packets(MaxQid, min_idx) = 0;
    else
        e_pkts = zeros(Width * Height, frame_num);
                    
        packet_error =  PacketError(DIR, frame_num, packets(1,min_idx1), 2);
        if (min_idx1 == 1)
            %first frame
            affect_frames = 8;
            offset = 0;
        else
            gop_idx = ceil((min_idx1-1) / 8);
            offset = (gop_idx-1)*8 + 1;
            affect_frames = 15;
            if (offset + affect_frames > frame_num)
                affect_frames = frame_num - offset;
            end
        end
        e_pkts(:,offset+1:offset+affect_frames) = e_pkts(:,offset+1:offset+affect_frames) + packet_error(:,1:affect_frames);

        discarded_size = discarded_size + pkt_length(packets(1,min_idx1));
        packets(1:MaxQid-1, min_idx1) = packets(2:MaxQid, min_idx1);
        packets(MaxQid, min_idx1) = 0;

        packet_error =  PacketError(DIR, frame_num, packets(1,min_idx2), 2);
        if (min_idx2 == 1)
            %first frame
            affect_frames = 8;
            offset = 0;
        else
            gop_idx = ceil((min_idx2-1) / 8);
            offset = (gop_idx-1)*8 + 1;
            affect_frames = 15;
            if (offset + affect_frames > frame_num)
                affect_frames = frame_num - offset;
            end
        end
        e_pkts(:,offset+1:offset+affect_frames) = e_pkts(:,offset+1:offset+affect_frames) + packet_error(:,1:affect_frames);

        discarded_size = discarded_size + pkt_length(packets(1,min_idx2));
        packets(1:MaxQid-1, min_idx2) = packets(2:MaxQid, min_idx2);
        packets(MaxQid, min_idx2) = 0;
        
        e_seq = e_seq + e_pkts;
        mse_seq = mean(e_seq.^2);
        psnr_seq = 10*log10(255^2./mse_seq);
        psnr_seq(psnr_seq > 99) = 99;
        psnr_seq = mean(psnr_seq);
    end
    
    display(['discarded ', num2str(discarded_size), ' out of ', num2str(task_size)]);
   
end

% extract
trc_ext = fopen([DIR, '\\trc\\extract-mine\\Orig', int2str(frame_num), '-ext', int2str(target_bytes) ,'bytes.txt'], 'w');
fseek(trc_ori, 0, 'bof');
for i = 1:2+ParamLines
    tline = fgetl(trc_ori);
    fprintf(trc_ext, [tline, '\r\n']);
end
i = 0;
while (feof(trc_ori) == 0)
    tline = fgetl(trc_ori);
    fprintf(trc_ext, [tline, '\r\n']);
    tline = fgetl(trc_ori);
    fprintf(trc_ext, [tline, '\r\n']);
    for j=1:MaxQid
        i = i+1;
        tline = fgetl(trc_ori);
        if(ismember(i, packets))
            fprintf(trc_ext, [tline, '\r\n']);
        end
    end
end

fclose(trc_ori);
fclose(trc_ext);