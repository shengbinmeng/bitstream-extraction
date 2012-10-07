function AssignPrioritySeq(DIR, frame_num, pri_vec_seq)

MaxQid = 2;
FrameNum = frame_num;

fid = fopen([DIR, '\\str\\', 'Foreman.264'], 'r');
stream_without_pri = fread(fid, Inf, 'uint8');
fclose(fid);

fid = fopen([DIR, '\\trc\\', 'Foreman.txt'], 'r');
fgetl(fid);
fgetl(fid);
C = textscan(fid, '%s%f%d%d%d%s%s%s');
fclose(fid);
len = C{2};
pos = zeros(FrameNum*MaxQid, 1);
for i = 1:FrameNum*MaxQid
pos(i) = sum(len(1:9+i+2*floor((i-1)/MaxQid))) + 5;
end

%enhencement layer (data that can be discarded)
pri_vec_el = pri_vec_seq(pri_vec_seq ~= Inf);

%assign priority
stream_with_my_pri = stream_without_pri;
stream_with_my_pri(pos) = stream_without_pri(pos) + pri_vec_el;

%write to file
fid = fopen([DIR, '\\str\\', 'Foreman_my_pri.264'], 'w');
fwrite(fid, stream_with_my_pri, 'uint8');
fclose(fid);


end