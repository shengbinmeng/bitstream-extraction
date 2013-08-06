function ModelVerify(DIR, frame_num)
% extract all the possible combinations of enhancement packet numbers in
% each frame in one GOP

trace = fopen([DIR, '\\trc\\Orig', int2str(frame_num), '.txt'], 'r');
MaxQid = 2;
Width = 352;
Height = 288;
ParamLine = 6;
BIN_PATH = '..\\bin';

fid_out = fopen(['result\\model-verify@', datestr(now, 'yyyymmddHHMMSS'), '.txt'], 'w');
for v0 = 1:MaxQid
    for v1 = 1:MaxQid
        for v21 = 1:MaxQid
            for v22 = 1:MaxQid
                for v31 = 1:MaxQid
                    for v32 = 1:MaxQid
                        for v33 = 1:MaxQid
                            for v34 = 1:MaxQid
                                fseek(trace, 0, 'bof');
                                file_name = ['Extract_Gop_', int2str(v0), int2str(v1), int2str(v21), int2str(v22), int2str(v31), int2str(v32), int2str(v33), int2str(v34)];
                                tmp = fopen([DIR, '\\trc\\', file_name, '.txt'], 'w');
                                for i = 1:2+ParamLine
                                    tline = fgetl(trace);
                                    fprintf(tmp, [tline, '\r\n']);
                                end
                                
                                % frm 0
                                for i = 1:2+MaxQid
                                    tline = fgetl(trace);
                                    fprintf(tmp, [tline, '\r\n']);
                                end
                                
                                % v0
                                for i = 1:2 %prefix and base layer
                                    tline = fgetl(trace);
                                    fprintf(tmp, [tline, '\r\n']);
                                end
                                for i = 1:v0
                                    tline = fgetl(trace);
                                    fprintf(tmp, [tline, '\r\n']);
                                end
                                for i = (v0+1):MaxQid
                                    fgetl(trace);
                                end
                                
                                % v1
                                
                                for i = 1:2
                                    tline = fgetl(trace);
                                    fprintf(tmp, [tline, '\r\n']);
                                end
                                for i = 1:v1
                                    tline = fgetl(trace);
                                    fprintf(tmp, [tline, '\r\n']);
                                end
                                for i = v1+1:MaxQid
                                    fgetl(trace);
                                end
                                
                                % v21
                                
                                for i = 1:2
                                    tline = fgetl(trace);
                                    fprintf(tmp, [tline, '\r\n']);
                                end
                                for i = 1:v21
                                    tline = fgetl(trace);
                                    fprintf(tmp, [tline, '\r\n']);
                                end
                                for i = v21+1:MaxQid
                                    fgetl(trace);
                                end
                                
                                % v22
                                
                                for i = 1:2
                                    tline = fgetl(trace);
                                    fprintf(tmp, [tline, '\r\n']);
                                end
                                for i = 1:v22
                                    tline = fgetl(trace);
                                    fprintf(tmp, [tline, '\r\n']);
                                end
                                for i = v22+1:MaxQid
                                    fgetl(trace);
                                end
                                
                               % v31
                                
                                for i = 1:2
                                    tline = fgetl(trace);
                                    fprintf(tmp, [tline, '\r\n']);
                                end
                                for i = 1:v31
                                    tline = fgetl(trace);
                                    fprintf(tmp, [tline, '\r\n']);
                                end
                                for i = v31+1:MaxQid
                                    fgetl(trace);
                                end
                                
                                % v32
                                
                                for i = 1:2
                                    tline = fgetl(trace);
                                    fprintf(tmp, [tline, '\r\n']);
                                end
                                for i = 1:v32
                                    tline = fgetl(trace);
                                    fprintf(tmp, [tline, '\r\n']);
                                end
                                for i = v32+1:MaxQid
                                    fgetl(trace);
                                end
                                
                                % v33
                                
                                for i = 1:2
                                    tline = fgetl(trace);
                                    fprintf(tmp, [tline, '\r\n']);
                                end
                                for i = 1:v33
                                    tline = fgetl(trace);
                                    fprintf(tmp, [tline, '\r\n']);
                                end
                                for i = v33+1:MaxQid
                                    fgetl(trace);
                                end
                                
                                % v34
                                
                                for i = 1:2
                                    tline = fgetl(trace);
                                    fprintf(tmp, [tline, '\r\n']);
                                end
                                for i = 1:v34
                                    tline = fgetl(trace);
                                    fprintf(tmp, [tline, '\r\n']);
                                end
                                for i = v34+1:MaxQid
                                    fgetl(trace);
                                end
                                
                                fclose(tmp);
                                
                                % decode and compare
                                fid = fopen('Extract.bat', 'w');
                                tline = [BIN_PATH, '\\BitStreamExtractorStatic ', DIR, '\\str\\Orig', int2str(frame_num), '.264 ', DIR, '\\str\\', file_name, '.264 -et ', DIR, '\\trc\\', file_name, '.txt \r\n',];
                                fprintf(fid, tline);
                                tline = [BIN_PATH, '\\H264AVCDecoderLibTestStatic ', DIR, '\\str\\', file_name, '.264 ', DIR, '\\yuv\\', file_name, '.yuv \r\n'];
                                fprintf(fid, tline);
                                fclose(fid);
                                
                                !Extract.bat
                                
                                extract_yuv = ReadYUV([DIR, '\\yuv\\', file_name, '.yuv'], Width, Height, 0, 8);
                                orig_yuv = ReadYUV([DIR, '\\yuv\\Orig.yuv'], Width, Height, 0, 8);
                                full_yuv = ReadYUV([DIR, '\\yuv\\Orig', int2str(frame_num), '-dec.yuv'], Width, Height, 0, 8);
                                extract_y = [];
                                orig_y = [];
                                full_y = [];
                                extract_y = [extract_y extract_yuv.Y];
                                orig_y = [orig_y orig_yuv.Y];
                                full_y = [full_y full_yuv.Y];
                                e_full = double(full_y) - double(orig_y);
                                
                                error = double(extract_y) - double(orig_y);
                                mse = sum(sum(error.^2))/(352*288*8);
                                
                                %error_est = zeros(Width*Height, 8);            %this means no ref
                                error_est = e_full;
                                for i = v0+1:MaxQid
                                    error_est = error_est + PacketError( DIR, frame_num, i+MaxQid,1);
                                end
                                for i = v1+MaxQid+1:MaxQid*2
                                    error_est = error_est + PacketError( DIR, frame_num, i+MaxQid,1);
                                end
                                for i = v21+MaxQid*2+1:MaxQid*3
                                    error_est = error_est + PacketError( DIR, frame_num, i+MaxQid,1);
                                end
                                for i = v22+MaxQid*3+1:MaxQid*4
                                    error_est = error_est + PacketError( DIR, frame_num, i+MaxQid,1);
                                end
                                for i = v31+MaxQid*4+1:MaxQid*5
                                    error_est = error_est + PacketError( DIR, frame_num, i+MaxQid,1);
                                end
                                for i = v32+MaxQid*5+1:MaxQid*6
                                    error_est = error_est + PacketError( DIR, frame_num, i+MaxQid,1);
                                end
                                for i = v33+MaxQid*6+1:MaxQid*7
                                    error_est = error_est + PacketError( DIR, frame_num, i+MaxQid,1);
                                end
                                for i = v34+MaxQid*7+1:MaxQid*8
                                    error_est = error_est + PacketError( DIR, frame_num, i+MaxQid,1);
                                end
                                
                                mse_est = sum(sum(error_est.^2))/(352*288*8);
                                
                                % Compare the estimated error matrices with
                                % the actual ones
                                diff = (mse_est - mse);
                                relative_diff = (mse_est - mse) / mse;
                                fprintf(fid_out, '%d %d %d %d %d %d %d %d %f %f %f %f\r\n', v0, v1, v21, v22, v31, v32, v33, v34, mse, mse_est, diff, relative_diff);                                
                            end
                        end
                    end
                end
            end
        end
    end
end

fclose(fid_out);
end