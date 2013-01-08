function priority_vector = ComputePriorityDiv(DIR, frame_num)
%

IDRPeriod = 32;

% for every SliceData packet(nalu) in the trace file, give it a priority num;
% prefix nalu and base layer nalu can't be discarded, so they have priority
% of Inf.
phi_vector = zeros((2 + MaxQid)*frame_num,1);
phi_vector(1:(2 + MaxQid):end) = Inf;
phi_vector(2:(2 + MaxQid):end) = Inf;

idr_num = (frame_num - 1) / IDRPeriod;
for i=1:idr_num
    idr_phi_vec = ComputePriorityIDR(DIR, frame_num, i);
    if(i == idr_num)
        phi_vector((i-1)*IDRPeriod+1 : (i-1)*IDRPeriod+IDRPeriod+1) = idr_phi_vec(1:IDRPeriod+1);
    else
        phi_vector((i-1)*IDRPeriod+1 : (i-1)*IDRPeriod+IDRPeriod) = idr_phi_vec(1:IDRPeriod);
    end
end


priority_vector = phi_vector;
save(['data\\', DIR(5:end), int2str(frame_num), '-priority-vector-div.mat'], 'priority_vector', 'discard_order');
%fclose(pri_data);
end