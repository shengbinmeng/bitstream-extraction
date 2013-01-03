function ExtractSubstreamOfRateDP(DIR, frame_num, target_bytes)

MaxQid = 2;
ParamLines = 6;

global g_dir;
global g_frame_num;
global g_width;
global g_height;
g_dir = DIR;
g_frame_num = frame_num;
g_width = 352;
g_height = 288;

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
%{
gop_packets = ...
[10	6	12	4	14	8	16	2;
 9	5	11	3	13	7	15	1];
%}
gop_num = (frame_num - 1)/8;
global g_packets;
g_packets = zeros(MaxQid, frame_num);
for i = 0:gop_num-1
    g_packets(:,i*8+2:i*8+9) = gop_packets + i * MaxQid*8 + MaxQid;
end
g_packets(:,1) = (MaxQid:-1:1)';


trc_ori = fopen([DIR, '\\trc\\Orig', int2str(frame_num), '.txt'], 'r');
for i = 1:2
    fgetl(trc_ori);
end
C = textscan(trc_ori, '%s%f%d%d%d%s%s%s');
len = C{2};
param_len = sum(len(1:ParamLines));
len = len(ParamLines+1:end);

basic_len = param_len + sum(len(1:(2 + MaxQid):end)) + sum(len(2:(2 + MaxQid):end));
enhence_len = target_bytes - basic_len;

lines = zeros(frame_num*MaxQid, 1);
for i = 0:frame_num-1
    lines(MaxQid*i+1 : MaxQid*i+MaxQid, 1) = 2 + ((MaxQid+2)*i+1 : (MaxQid+2)*i+MaxQid);
end
global g_pkt_length;
g_pkt_length = len(lines, 1);

global g_select;
global g_packet_num;
g_packet_num = MaxQid*frame_num;
g_select = zeros(g_packet_num, 1);
OptValue(g_packet_num, enhence_len);

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
        if(g_select(i) == 1)
            fprintf(trc_ext, [tline, '\r\n']);
        end
    end
end

fclose(trc_ori);
fclose(trc_ext);