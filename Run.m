function Run(SEQ, frame_num)
ErrorVector(SEQ, frame_num);
priority_vector = ComputePriority(SEQ, frame_num);
ExtractSubstreamTest(SEQ, frame_num, priority_vector);
ExtractSubstreamQL(SEQ, frame_num);
ExtractSubstreamBasic(SEQ, frame_num);
CalculateRD(SEQ, frame_num);
PlotDataRD(frame_num);
end