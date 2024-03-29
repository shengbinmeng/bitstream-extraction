function priority_vector = ComputePriority(DIR, frame_num)
%

Width = 352;
Height = 288;
MaxQid = 2;
ParamLine = 6;

pos = strfind(DIR, '\');
a = length(pos);
if(a ~= 0) 
    a = pos(a);
end
last_folder = DIR(a+1 : end);

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
%}
gop_num = (frame_num - 1)/8;
packets = zeros(MaxQid, frame_num);
for i = 0:gop_num-1
    packets(:,i*8+2:i*8+9) = gop_packets + i * MaxQid*8 + MaxQid;
end
packets(:,1) = (MaxQid:-1:1)';

trace = fopen([DIR, '\\trc\\Orig', int2str(frame_num), '.txt'], 'r');
for i = 1:2+ParamLine
    fgetl(trace);
end

C = textscan(trace, '%s%f%d%d%d%s%s%s', frame_num * (MaxQid+2));
lines = zeros(frame_num*MaxQid, 1);
for i = 0:frame_num-1
    lines(MaxQid*i+1 : MaxQid*i+MaxQid, 1) = 2 + ((MaxQid+2)*i+1 : (MaxQid+2)*i+MaxQid);
end
pkt_length = C{2}(lines, 1);
fclose(trace);

%pri_data = fopen(['data\\', last_folder, int2str(frame_num), '-pri-data.txt'], 'w');
select_map = ones(1, frame_num) * (1+MaxQid);
distortion_seq = EstimateDistortion(DIR, select_map, frame_num);
for j = 1:MaxQid*frame_num
    phi_pkt = zeros(1, frame_num);
    for i = 1:frame_num
        select_map_next = select_map;
        select_map_next(i) = select_map(i) - 1;
        if select_map_next(i) == 0
            % next is base layer
            phi_pkt(i) = Inf;
            continue;
        end
        
        distortion_pkt = EstimateDistortion(DIR, select_map_next, frame_num);
        mse_seq = sum(distortion_seq);
        mse_pkt = sum(distortion_pkt);
        delta_d = mse_pkt - mse_seq;
        delta_r = pkt_length(packets(MaxQid+1 - select_map_next(i),i));
        phi_pkt(i) = abs(delta_d)/(delta_r/1000);
        
        %fprintf(pri_data, '%d %d %f %f %f %d %f \r\n', i, packets(MaxQid+1 - select_map_next(i),i), mse_seq, mse_pkt, delta_d, delta_r, phi_pkt(i));
    end

    [the_phi, the_idx] = min(phi_pkt);
    select_map(the_idx) = select_map(the_idx) - 1;
    display([the_phi, packets(MaxQid+1 - select_map(the_idx), the_idx)]);
    
    discard_order = cat(2, discard_order, packets(MaxQid+1 - select_map(the_idx), the_idx));
    priority_vector(ceil(packets(MaxQid+1 - select_map(the_idx), the_idx)/MaxQid)*2 + packets(MaxQid+1 - select_map(the_idx), the_idx)) = j;

    distortion_seq = EstimateDistortion(DIR, select_map, frame_num);
end

save(['data\\', last_folder, int2str(frame_num), '-priority-vector.mat'], 'priority_vector', 'discard_order');
%fclose(pri_data);
end