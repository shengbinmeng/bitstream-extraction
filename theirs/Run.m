function Run(DIR, frame_num)
SelfDistortion(DIR, frame_num);
DriftData(DIR, frame_num);
DriftParams(frame_num);
priority_vector = ComputePriority(DIR, frame_num);
ExtractSubstreamMine(DIR, frame_num, priority_vector);
ExtractSubstreamQL(DIR, frame_num);
ExtractSubstreamBasic(DIR, frame_num);
CalculateRD(DIR, frame_num);
PlotDataRD(frame_num);
end