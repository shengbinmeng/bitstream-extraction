function ExtractSubstream(IDR, frame_num, pri_vec_seq, target_bytes)
SeqFrameNum = frame_num - 1; % first frame not included
GroupFrameNum = 32;
MaxQid = 2;
MaxPriority = MaxQid * GroupFrameNum -1;

trc_ori = fopen([DIR, '\\trc\\', 'Foreman.txt'], 'r');
for i = 1:10
    fgetl(trc_ori);
end
C = textscan(trc_ori, '%s%f%d%d%d%s%s%s');
len = C{2};

for k = 0:MaxPriority
    extract_bytes = sum(len(pri_vec_seq >= k));
    if (extract_bytes < target_bytes)
        break;
    end
end

trc_ext = fopen([DIR, '\\trc\Foreman-ext.txt'], 'w');
fseek(trc_ori, 0, 'bof');
for i = 1:10
    tline = fgetl(trc_ori);
    fprintf(trc_ext, [tline, '\r\n']);
end
for i = 1:2:SeqFrameNum*MaxQid
    for j = 0:1
        tline = fgetl(trc_ori);
        fprintf(trc_ext, [tline, '\r\n']);
    end
    for j = 0:1
        tline = fgetl(trc_ori);
        if(pri_vec_seq(i+j) >= k)
            fprintf(trc_ext, [tline, '\r\n']);
        else
            %discard
        end
    end
end

fclose(trc_ori);
fclose(trc_ext);

end