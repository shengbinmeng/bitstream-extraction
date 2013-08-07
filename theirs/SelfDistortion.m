function self_distortion = SelfDistortion(DIR, frame_num)

TemporalLevelPos = 28;
QualityLevelPos = 33;
Width = 352;
Height = 288;
MaxQid = 2;
MaxTid = 3;
ParamLines = 6;
BIN_PATH = '..\\bin';

pos = strfind(DIR, '\');
a = length(pos);
if(a ~= 0) 
    a = pos(a);
end
last_folder = DIR(a+1 : end);

trace = fopen([DIR, '\\trc\\Orig', int2str(frame_num), '.txt'], 'r');

self_distortion = zeros(MaxQid+1, frame_num);
for tlayer = 0:MaxTid
    for qlayer = MaxQid:-1:0
        fseek(trace, 0, 'bof');
        file_name = ['Discard_Group_t', int2str(tlayer), 'q', int2str(qlayer)];
        tmp = fopen([DIR, '\\trc\\', file_name, '.txt'], 'w');
        % read parameter set
        for i = 1:2+ParamLines
            tline = fgetl(trace);
            fprintf(tmp, [tline, '\r\n']);
        end
        while (feof(trace) == 0)
            tline = fgetl(trace);
            tid = tline(TemporalLevelPos) - '0';
            qid = tline(QualityLevelPos) - '0';

            if (tid == tlayer && qid > qlayer)
                %discard
            else
                fprintf(tmp, [tline, '\r\n']);
            end
        end
        fclose(tmp);
        
        % extract and decode
        fid = fopen('Extract.bat', 'w');
        tline = [BIN_PATH, '\\BitStreamExtractorStatic ', DIR, '\\str\\Orig', int2str(frame_num), '.264 ', DIR, '\\str\\', file_name, '.264 -et ', DIR, '\\trc\\', file_name, '.txt \r\n',];
        fprintf(fid, tline);
        tline = [BIN_PATH, '\\H264AVCDecoderLibTestStatic ', DIR, '\\str\\', file_name, '.264 ', DIR, '\\yuv\\', file_name, '.yuv \r\n'];
        fprintf(fid, tline);
        fclose(fid);
        !Extract.bat
        
        ref_name = ['Orig', int2str(frame_num), '-dec'];
        frames_ref = ReadYUV([DIR, '\\yuv\\', ref_name, '.yuv'], Width, Height, 0, frame_num);
        frames = ReadYUV([DIR, '\\yuv\\', file_name, '.yuv'], Width, Height, 0, frame_num);
        for frm = 1:frame_num
            if (mod(frm, 8) == 1)
                t = 0;
            elseif (mod(frm, 8) == 5)
                t = 1;
            elseif (mod(frm, 8) == 3 || mod(frm, 8) == 7)
                t = 2;
            elseif (mod(mod(frm, 8), 2) == 0)
                t = 3;
            end
            
            if (t == tlayer)
                error = double(frames(frm).Y) - double(frames_ref(frm).Y);
                sse = sum(error.^2);
                display(sse);
                self_distortion(qlayer+1, frm) = sse;
            end
        end
    end 
end

save(['data\\', last_folder, int2str(frame_num), '-self-distortion.mat'], 'self_distortion');