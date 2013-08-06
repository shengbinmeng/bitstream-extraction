function Run(DIR, frame_num)
SelfDistortion(DIR, frame_num);
DriftData(DIR, frame_num);
DriftParams(frame_num);
ComputePriority(DIR, frame_num);
ObtainRD(DIR, frame_num);
%PlotDataRD(DIR, frame_num);
end