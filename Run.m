function Run(DIR, frame_num)
ErrorVector(DIR, frame_num);
ComputePriorityIDR(DIR, frame_num);
ObtainRD(DIR, frame_num);
PlotDataRD(DIR,frame_num);
end