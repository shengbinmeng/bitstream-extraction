function ExtractSubstreamOfRate(DIR, frame_num, pri_vec, target_bytes)

MaxQid = 2;
ParamLines = 6;

trc_ori = fopen([DIR, '\\trc\\Orig', int2str(frame_num), '.txt'], 'r');
for i = 1:2
    fgetl(trc_ori);
end
C = textscan(trc_ori, '%s%f%d%d%d%s%s%s');
len = C{2};
param_len = sum(len(1:ParamLines));
len = len(ParamLines+1:end);

for k = frame_num * MaxQid:-1:-1
    extract_bytes = sum(len(pri_vec > k)) + param_len;
    %next_extract_bytes = sum(len(pri_vec >= k+1));
    if (extract_bytes > target_bytes)
        break;
    end
end
%k = k + 1; % ensure extract_bytes < target_bytes; maybe no need

trc_ext = fopen([DIR, '\\trc\\extract-mine\\Orig', int2str(frame_num), '-ext', int2str(target_bytes) ,'bytes.txt'], 'w');
fseek(trc_ori, 0, 'bof');
for i = 1:2+ParamLines
    tline = fgetl(trc_ori);
    fprintf(trc_ext, [tline, '\r\n']);
end
i = 0;
while (feof(trc_ori) == 0)
    tline = fgetl(trc_ori);
    i = i+1;
    if(pri_vec(i) > k)
        fprintf(trc_ext, [tline, '\r\n']);
    else
        %discard
    end
end

fclose(trc_ori);
fclose(trc_ext);