function drift_data = DriftData(DIR, frame_num)

TemporalLevelPos = 28;
QualityLevelPos = 33;
Width = 352;
Height = 288;
MaxQid = 2;
MaxTid = 3;
ParamLines = 6;
SampleNum = 20;
BIN_PATH = '..\\bin';

data = zeros(3, frame_num, SampleNum);
trace = fopen([DIR, '\\trc\\Orig', int2str(frame_num), '.txt'], 'r');
for tlayer = MaxTid:-1:1
    for k = 1:SampleNum
        fseek(trace, 0, 'bof');
        file_name = ['Discard-Rand-t', int2str(tlayer), '-Sample', int2str(k)];
        tmp = fopen([DIR, '\\trc\\', file_name, '.txt'], 'w');
        for i = 1:2+ParamLines
            tline = fgetl(trace);
            fprintf(tmp, [tline, '\r\n']);
        end
        while (feof(trace) == 0)
            tline = fgetl(trace);
            tid = tline(TemporalLevelPos) - '0';
            qid = tline(QualityLevelPos) - '0';
            
            if (qid == 0)
                % every qid == 0, update rand_id(0-5)
                rand_id = ceil((MaxQid+1)*rand()) - 1; % 0-5
            end

            if (tid < tlayer && qid > rand_id)
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
                if (t == 3)
                    ref1 = frm - 1;
                    ref2 = frm + 1;
                elseif (t == 2)
                    ref1 = frm - 2;
                    ref2 = frm + 2;
                elseif (t == 1)
                    ref1 = frm - 4;
                    ref2 = frm + 4;
                end
                
                error = double(frames(frm).Y) - double(frames_ref(frm).Y);
                sse = sum(error.^2);
                data(1, frm, k) = sse;
                error = double(frames(ref1).Y) - double(frames_ref(ref1).Y);
                sse = sum(error.^2);
                data(2, frm, k) = sse;
                error = double(frames(ref2).Y) - double(frames_ref(ref2).Y);
                sse = sum(error.^2);
                data(3, frm, k) = sse;
            end
        end
    end
end
fclose(trace);
drift_data = data;
save('data\\drift-data.mat', 'drift_data');
end