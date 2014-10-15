function C = normxcorr2_general_CL(A, B, block_size)

[C, numberOfOverlapPixels] = normxcorr2_general(A, B, 0);

mask = zeros(size(C, 1), size(C, 2));
mask((size(C, 1) - 1)/2 - block_size:(size(C, 1) - 1)/2 + block_size, (size(C, 2) - 1)/2 - block_size:(size(C, 2) - 1)/2 + block_size) = 1;
C = C.*mask;
