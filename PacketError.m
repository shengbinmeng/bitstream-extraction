function packet_error = PacketError(DIR, frame_num, pkt_idx, gop_num)
%
% pkt_idx is the index of the packet in the whold sequence;
% gop_num is the returned packet_error's size (will cover how many gops counting from
% the gop of the packet);


MaxQid = 2;
Width = 352;
Height = 288;

if (pkt_idx <= 2)
    qid = MaxQid - mod(pkt_idx, MaxQid);
    file_name = ['Discard_Group_t0q', int2str(qid), '_even'];
    error_vector = [];
    load(['data\\', DIR(5:end), int2str(frame_num), '-', file_name, '-err.mat'], 'error_vector');
    packet_error = zeros(Width*Height, 8*gop_num);
    packet_error(:,1:8) = error_vector(:,1:8);
    return;
end
pkt_idx = pkt_idx - 2;
gop_idx = ceil((pkt_idx)/(8*MaxQid)); %1, 2, ...
pkt_idx = pkt_idx - 8*MaxQid * (gop_idx-1); % 1, 2, ..., 16

if (pkt_idx <= MaxQid)
    frame_idx = 8;
    tid = 0;
elseif (pkt_idx <= 2*MaxQid)
    frame_idx = 4;
    tid = 1;
elseif (pkt_idx <= 3*MaxQid)
    frame_idx = 2;
    tid = 2;
elseif (pkt_idx > 3*MaxQid && pkt_idx <= 5*MaxQid)
    frame_idx = 1 + 2*(ceil((pkt_idx - 3*MaxQid)/MaxQid)-1);
    tid = 3;
elseif (pkt_idx > 5*MaxQid && pkt_idx <= 6*MaxQid)
    frame_idx = 6;
    tid = 2;
elseif (pkt_idx > 6*MaxQid)
    frame_idx = 5 + 2*(ceil((pkt_idx - 6*MaxQid)/MaxQid)-1);
    tid = 3;
end

qid = MaxQid - mod(pkt_idx, MaxQid);
if (tid == 0)
    if (mod(gop_idx, 2) == 0)
        file_name = ['Discard_Group_t0q', int2str(qid), '_even'];
    else
        file_name = ['Discard_Group_t0q', int2str(qid), '_odd'];
    end
else
    file_name = ['Discard_Group_t', int2str(tid), 'q', int2str(qid)];
end

error_vector = [];
load(['data\\', DIR(5:end), int2str(frame_num), '-', file_name, '-err.mat'], 'error_vector');
packet_error = zeros(Width*Height, 8*gop_num);
offset = (gop_idx-1)*8 + 1;
if (tid == 0)
    if (gop_num > 1)
        frames = 15;
        if (offset + frames > length(error_vector(1,:)))
            frames = length(error_vector(1,:)) - offset;
        end
    else
        frames = 8;
    end
    packet_error(:,1:frames) = error_vector(:,(offset+1):(offset+frames));
elseif (tid == 1)
    packet_error(:,(frame_idx-3):(frame_idx+3)) = error_vector(:,(offset+frame_idx-3):(offset+frame_idx+3));
elseif (tid == 2)
    packet_error(:,(frame_idx-1):(frame_idx+1)) = error_vector(:,(offset+frame_idx-1):(offset+frame_idx+1));
elseif (tid == 3)
    packet_error(:,(frame_idx-0):(frame_idx+0)) = error_vector(:,(offset+frame_idx-0):(offset+frame_idx+0));
end

end