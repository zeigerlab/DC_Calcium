function [data,frame_count] = load_tiff_simple(file_name)
%LOAD_TIFF_SIMPLE   Load image stacks from a TIFF file.
%   This function assumes the input file is a typical TIFF generated while
%   two-photon imaging, i.e. ScanImage, which should be a simple, grayscale
%   image stack in signed 16-bit integers. It might not work for other
%   types of TIFF files.
%
%   This function uses MATLAB's implementation of LibTIFF library routines
%   to read data stored in the TIFF file. As of R2018b, there is still a
%   memory leak in calling read in mode 'r', causing this function to use
%   twice as large memory as the original uncompressed file size. Keep this
%   in mind when you are dealing with very large TIFF files.

tiff = Tiff(file_name,'r');

length = tiff.getTag('ImageLength');
width = tiff.getTag('ImageWidth');

frame_count = 1;
while ~tiff.lastDirectory
    frame_count = frame_count+1;
    tiff.nextDirectory
end

temp = tiff.read;
data = zeros(length,width,frame_count,'like',temp);

for cur_frame = 1:frame_count
    tiff.setDirectory(cur_frame)
    data(:,:,cur_frame) = tiff.read;
end

tiff.close
end