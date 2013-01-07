function priority_vector = ComputePriorityDiv(DIR, frame_num)
%

Width = 352;
Height = 288;
MaxQid = 2;
ParamLines = 6;
IDRPeriod = 32;

% for every SliceData packet(nalu) in the trace file, give it a priority num;
% prefix nalu and base layer nalu can't be discarded, so they have priority
% of Inf.
priority_vector = zeros((2 + MaxQid)*frame_num,1);
priority_vector(1:(2 + MaxQid):end) = Inf;
priority_vector(2:(2 + MaxQid):end) = Inf;

idr_num = (frame_num - 1) / IDRPeriod;
for i=1:idr_num
end

save(['data\\', DIR(5:end), int2str(frame_num), '-priority-vector-div.mat'], 'priority_vector', 'discard_order');
%fclose(pri_data);
end