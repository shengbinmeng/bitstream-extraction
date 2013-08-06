function [frames file_data] = ReadYUV(filename, width, height, skip, frame_num)
fid = fopen(filename, 'rb');
y_size = width * height;
offset = skip * y_size * 3/2;
fseek(fid, offset, 'bof');
frames = [];
for i=1:frame_num
    frame.Y = uint8(fread(fid, y_size, 'uint8'));
    frame.U = uint8(fread(fid, y_size * 1/4, 'uint8'));
    frame.V = uint8(fread(fid, y_size * 1/4, 'uint8'));
    frames = [frames frame];
end

fseek(fid, offset, 'bof');
file_data = uint8(fread(fid, y_size * 3/2 * frame_num, 'uint8'));
fclose(fid);
end