function value = OptValue(num, bound)
global g_select;
global g_packet_num;
global g_pkt_length;
global g_dir;
global g_frame_num;
global g_width;
global g_height;
global g_packets;
MaxQid = 2;

display(num);
display(bound);

if (num <= 0 || bound <= 0)
    value = Inf;
    return;
end

for i = num:-1:1
    % need to select packets below i
    below = mod(MaxQid-1+mod(i,MaxQid), MaxQid);
   if (sum(g_pkt_length(i-below:i)) > bound) 
        display(i);
        display('not selected !');
        value = OptValue(i-1, bound);
        g_select(i) = 0;
        return;
   else
        % not select packet i
        temp1 = OptValue(i-1, bound);
        % select packet i
        select_temp2 = zeros(g_packet_num,1);
        OptValue(i-1-below, bound - sum(g_pkt_length(i-below:i)));
        e_temp2 = zeros(g_width * g_height, g_frame_num);
        for j = 1:1:i-1-below
            select_temp2(j) = g_select(j);
        end
        for j = i-below:1:i
            select_temp2(j) = 1;
        end
        for j = i+1:1:g_packet_num
            select_temp2(j) = g_select(j);
        end

        for j = 1:g_packet_num
            if (select_temp2(j) == 0)
                packet_error = PacketError(g_dir, g_frame_num, j, 2);
                [row, col] = find(g_packets == j);
                if (col == 1)
                    %first frame
                    affect_frames = 8;
                    offset = 0;
                else
                    gop_idx = ceil((col-1) / 8);
                    offset = (gop_idx-1)*8 + 1;
                    affect_frames = 15;
                    if (offset + affect_frames > g_frame_num)
                        affect_frames = g_frame_num - offset;
                    end
                end
                e_temp2(:,offset+1:offset+affect_frames) = e_temp2(:,offset+1:offset+affect_frames) + packet_error(:,1:affect_frames);   
            end
        end

        temp2 = sum(mean((e_temp2).^2));
        
        if (temp1 < temp2)
            g_select(i) = 0;
            value = temp1;
            display(i);
            display('not selected !');
            return;
        else
            g_select(i) = 1;
            value = temp2;
            display(i);
            display('selected !');
            return;
        end
            
   end
       
end

end