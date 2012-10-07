function pri_vec_seq = ComputePrioritySeq(DIR, frame_num)

SeqFrameNum = frame_num - 1; % first frame not included
GroupFrameNum = 32;
MaxQid = 2;

pri_vec_seq = zeros(SeqFrameNum * (2+MaxQid),1);
for i = 1: floor(SeqFrameNum/GroupFrameNum)
    [dis, pri] = ComputePriority(DIR, 1+(i-1)*GroupFrameNum, GroupFrameNum);
    pri_vec_seq(1 + (i-1)*GroupFrameNum*(2+MaxQid): GroupFrameNum*(2+MaxQid) + (i-1)*GroupFrameNum*(2+MaxQid)) = pri;
end
[dis, pri] = ComputePriority(DIR, 1+i*GroupFrameNum, SeqFrameNum - i*GroupFrameNum);
pri_vec_seq(1 + i*GroupFrameNum*(2+MaxQid): SeqFrameNum - (i*GroupFrameNum)*(2+MaxQid) + i*GroupFrameNum*(2+MaxQid)) = pri;
    
end