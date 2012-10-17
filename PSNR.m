function psnr = PSNR (ori_file, rec_file, width, height, frame_num)

ori_yuv = ReadYUV(ori_file, width, height, 0, frame_num);
rec_yuv = ReadYUV(rec_file, width, height, 0, frame_num);
ori_y = [];
rec_y = [];
ori_y = [ori_y ori_yuv.Y];
rec_y = [rec_y rec_yuv.Y];

mse = mean((double(rec_y) - double(ori_y)).^2);
psnr_frames = 10*log10(255^2./mse);
psnr_frames(psnr_frames == Inf) = 99.99;
psnr = mean(psnr_frames);

end