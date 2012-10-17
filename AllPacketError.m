function pkt_err_all = AllPacketError(frame_num)
% compute error vector of every packet (run by group)

Width = 352;
Height = 288;
MaxQid = 2;
MaxTid = 3;
gop_num = frame_num / 8;
pkt_err_all = int16(zeros(frame_num * MaxQid, Width*Height, 15));
for qlayer = MaxQid:-1:1
    file_name = ['Discard_Group_t0q', int2str(qlayer), '_odd'];
    file_name1 = ['Discard_Group_t0q', int2str(qlayer), '_even'];
    error_vector = load(['data\\', file_name, '-err.mat']);
    for gop_idx = 1:2:gop_num
        offset = (gop_idx-1)*8;
        frames = length(error_vector(1,:)) - offset;
        if (frames > 15)
            frames = 15;
        end
        pkt_err_all(0 + qlayer + (gop_idx-1)*8*MaxQid, :, 1:frames) = error_vector(:,(offset+1):(offset+frames));
    end
    
    error_vector = load(['data\\', file_name1, '-err.mat']);
    for gop_idx = 2:2:gop_num
        offset = (gop_idx-1)*8;
        frames = length(error_vector(1,:)) - offset;
        if (frames > 15)
            frames = 15;
        end
        pkt_err_all(0 + qlayer + (gop_idx-1)*8*MaxQid, :, 1:frames) = error_vector(:,(offset+1):(offset+frames));
    end
    
    for tlayer = 1:MaxTid
        file_name = ['Discard_Group_t', int2str(tlayer), 'q', int2str(qlayer)];
        error_vector = load(['data\\', file_name, '-err.mat']);
        if (tlayer == 1)
            frame_idx = 4;
            for gop_idx = 1:gop_num
                offset = (gop_idx-1)*8;
                pkt_err_all(MaxQid*1 + qlayer + (gop_idx-1)*8*MaxQid, :, frame_idx-3:frame_idx+3) = error_vector(:,(offset+frame_idx-3):(offset+frame_idx+3));
            end
        elseif (tlayer == 2)
            frame_idx = 2;
            for gop_idx = 1:gop_num
                offset = (gop_idx-1)*8;
                pkt_err_all(MaxQid*2 + qlayer + (gop_idx-1)*8*MaxQid, :, frame_idx-1:frame_idx+1) = error_vector(:,(offset+frame_idx-1):(offset+frame_idx+1));
            end
            frame_idx = 5;
            for gop_idx = 1:gop_num
                offset = (gop_idx-1)*8;
                pkt_err_all(MaxQid*3 + qlayer + (gop_idx-1)*8*MaxQid, :, frame_idx-1:frame_idx+1) = error_vector(:,(offset+frame_idx-1):(offset+frame_idx+1));
            end
        elseif (tlayer == 3)
            for frame_idx = 1:2:7
                for gop_idx = 1:gop_num
                    offset = (gop_idx-1)*8;
                    pkt_err_all(MaxQid*(3+ceil(frame_idx/2)) + qlayer + (gop_idx-1)*8*MaxQid, :, frame_idx-0:frame_idx+0) = error_vector(:,(offset+frame_idx-0):(offset+frame_idx+0));
                end
            end
        end  
    end
end

save(['data\\', 'pkt_err_all.mat'], 'pkt_err_all');
end