function ExtractSubstreamOfRate(SEQ, frame_num, pri_vec, target_bytes)

MaxQid = 2;
DIR = ['..\\', SEQ];
trc_ori = fopen([DIR, '\\trc\\', SEQ, int2str(frame_num), '.txt'], 'r');
for i = 1:10
    fgetl(trc_ori);
end
C = textscan(trc_ori, '%s%f%d%d%d%s%s%s');
len = C{2};

for k = 1:frame_num * MaxQid
    extract_bytes = sum(len(pri_vec >= k));
    next_extract_bytes = sum(len(pri_vec >= k+1));
    if (abs(extract_bytes - target_bytes) < abs(next_extract_bytes - target_bytes))
        break;
    end
end
k = k -1 ; % I'd rather have more bytes left

trc_ext = fopen([DIR, '\\trc\\', SEQ, int2str(frame_num), '-ext.txt'], 'w');
fseek(trc_ori, 0, 'bof');
for i = 1:10
    tline = fgetl(trc_ori);
    fprintf(trc_ext, [tline, '\r\n']);
end
for i = 1:frame_num*MaxQid
    tline = fgetl(trc_ori);
    if(pri_vec(i) >= k)
        fprintf(trc_ext, [tline, '\r\n']);
    else
        %discard
    end
end

fclose(trc_ori);
fclose(trc_ext);