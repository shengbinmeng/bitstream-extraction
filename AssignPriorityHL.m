function AssignPriorityHL(DIR, discard_order)

MaxQid = 2;
FrameNum = 32;

%find positions for modification
fid = fopen([DIR, '\\str\\', 'Foreman-33frm.264'], 'r');
stream_without_pri = fread(fid, Inf, 'uint8');
fclose(fid);
fid = fopen([DIR, '\\str\\', 'Foreman-33frm-ql.264'], 'r');
stream_with_pri = fread(fid, Inf, 'uint8');
fclose(fid);
e = stream_with_pri - stream_without_pri;
pos = find(e);
pri_ql = stream_with_pri(pos);
pri_ql = bitset(pri_ql, 7, 0);
pri_ql = bitset(pri_ql, 8, 0);


fid = fopen([DIR, '\\trc\\', 'Foreman-33frm.txt'], 'r');
tline = fgetl(fid);
tline = fgetl(fid);
C = textscan(fid, '%s%f%d%d%d%s%s%s');
fclose(fid);
len = C{2};
pos2 = zeros(FrameNum*MaxQid, 1);
for i = 1:FrameNum*MaxQid
pos2(i) = sum(len(1:9+i+2*floor((i-1)/MaxQid))) + 5; % 5 = 4(bytes of prefix) + 1(byte of AVC header)
end

pri_vec = zeros(1, FrameNum*MaxQid);
pri_vec(discard_order) = 1 : FrameNum*MaxQid;

%assign priority
stream_with_my_pri = stream_without_pri;
stream_with_my_pri(pos2) = stream_without_pri(pos2) + pri_vec;

%write to file
fid = fopen([DIR, '\\str\\', 'Foreman-pri.264'], 'w');
fwrite(fid, stream_with_my_pri, 'uint8');
fclose(fid);


end