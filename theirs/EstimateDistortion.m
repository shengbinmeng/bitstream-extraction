function distortion = EstimateDistortion(selection_map, frame_num)

MaxTid = 3;
MaxQid = 5;
Width = 352;
Height = 288;
data = load('data\\self-distortion.mat');
self_distortion = data.self_distortion;
data = load('data\\drift-params.mat');
drift_params = data.drift_params;
%selection_map = zeros(1, frame_num);
self_part = zeros(1, frame_num);
drift_part = zeros(1, frame_num);
total_distortion = zeros(1, frame_num);
param_k = 0.001;
for tlayer = 0:1:MaxTid
    if (tlayer == 0)
        frame_idx = 1:8:frame_num;
        for i = 1:size(frame_idx,2)
            frm = frame_idx(i);
            total_distortion(frm) = self_distortion(selection_map(frm), frm);
            self_part(frm) = total_distortion(frm);
        end
    elseif (tlayer == 1)
        frame_idx = 5:8:frame_num;
        for i = 1:size(frame_idx,2)
            frm = frame_idx(i);
            ref1 = frm - 4;
            ref2 = frm + 4;
            p = drift_params(:,frm);
            d_ref1 = total_distortion(ref1);
            d_ref2 = total_distortion(ref2);
            d_drift = p(1)*d_ref1 + p(2)*d_ref2 + p(3)*d_ref1^2 + p(4)*d_ref2^2 + p(5)*d_ref1*d_ref2;
            d_self = self_distortion(selection_map(frm), frm);
            d_total = d_drift + d_self + 2*param_k*(d_drift*d_self)^0.5;
            total_distortion(frm) = d_total;
            self_part(frm) = d_self;
            drift_part(frm) = d_drift;
        end
    elseif (tlayer == 2)
        frame_idx = 3:4:frame_num;
        for i = 1:size(frame_idx,2)
            frm = frame_idx(i);
            ref1 = frm - 2;
            ref2 = frm + 2;
            p = drift_params(:,frm);
            d_ref1 = total_distortion(ref1);
            d_ref2 = total_distortion(ref2);
            d_drift = p(1)*d_ref1 + p(2)*d_ref2 + p(3)*d_ref1^2 + p(4)*d_ref2^2 + p(5)*d_ref1*d_ref2;
            d_self = self_distortion(selection_map(frm), frm);
            d_total = d_drift + d_self + 2*param_k*(d_drift*d_self)^0.5;
            total_distortion(frm) = d_total;
            self_part(frm) = d_self;
            drift_part(frm) = d_drift;
        end
    elseif (tlayer == 3)
        frame_idx = 2:2:frame_num;
        for i = 1:size(frame_idx,2)
            frm = frame_idx(i);
            ref1 = frm - 1;
            ref2 = frm + 1;
            p = drift_params(:,frm);
            d_ref1 = total_distortion(ref1);
            d_ref2 = total_distortion(ref2);
            d_drift = p(1)*d_ref1 + p(2)*d_ref2 + p(3)*d_ref1^2 + p(4)*d_ref2^2 + p(5)*d_ref1*d_ref2;
            d_self = self_distortion(selection_map(frm), frm);
            d_total = d_drift + d_self + 2*param_k*(d_drift*d_self)^0.5;
            total_distortion(frm) = d_total;
            self_part(frm) = d_self;
            drift_part(frm) = d_drift;
        end
    end
end

distortion_mse = total_distortion/(Width*Height);
%distortion_psnr = 10*log10(255^2 ./ distortion_mse);
distortion = distortion_mse;
save('data\\part.mat', 'self_part', 'drift_part');
end