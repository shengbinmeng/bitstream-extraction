
set NUM=33
..\bin\H264AVCEncoderLibTestStatic -pf cfg\main.cfg -bf str\Orig%NUM%.264 -frms %NUM%
..\bin\BitStreamExtractorStatic  -pt trc\Orig%NUM%.txt str\Orig%NUM%.264
..\bin\QualityLevelAssignerStatic -in str\Orig%NUM%.264 -org 0 yuv\Orig.yuv -out str\Orig%NUM%-ql.264 -wp tmp\Orig%NUM%-qldata.txt
..\bin\H264AVCDecoderLibTestStatic str\Orig%NUM%.264 yuv\Orig%NUM%-dec.yuv
..\bin\QualityLevelAssignerStatic -in str\Orig%NUM%.264 -org 0 yuv\Orig%NUM%-dec.yuv -out str\Orig%NUM%-ql-noref.264 -wp tmp\Orig%NUM%-qldata-noref.txt




