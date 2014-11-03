function [match_A2B, match_B2A] = func_bds(A_patches, B_patches)

% for every patch in A_patches, find its closest match in B_patches
M_A2B  = pdist2(A_patches, B_patches);
[minc, match_A2B] = min(M_A2B,  [], 2);
[minc, match_B2A] = min(M_A2B',  [], 2);
