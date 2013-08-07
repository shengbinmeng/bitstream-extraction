function Run(DIR, frame_num)
ErrorVector(DIR, frame_num);
ComputePriority(DIR, frame_num);
ObtainRD(DIR, frame_num);
PlotDataRD(DIR,frame_num);
end