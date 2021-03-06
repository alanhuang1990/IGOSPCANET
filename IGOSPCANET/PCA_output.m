function [OutImg OutImgIdx] = PCA_output(InImg, InImgIdx, PatchSize, NumFilters, V)
% Computing PCA filter outputs
% ======== INPUT ============
% InImg         Input images (cell structure); each cell can be either a matrix (Gray) or a 3D tensor (RGB)   
% InImgIdx      Image index for InImg (column vector)
% PatchSize     Patch size (or filter size); the patch is set to be sqaure
% NumFilters    Number of filters at the stage right before the output layer 
% V             PCA filter banks (cell structure); V{i} for filter bank in the ith stage  
% ======== OUTPUT ===========
% OutImg           filter output (cell structure)
% OutImgIdx        Image index for OutImg (column vector)
% ========= CITATION ============
% T.-H. Chan, K. Jia, S. Gao, J. Lu, Z. Zeng, and Y. Ma, 
% "PCANet: A simple deep learning baseline for image classification?" submitted to IEEE TPAMI. 
% ArXiv eprint: http://arxiv.org/abs/1404.3606 

% Tsung-Han Chan [thchan@ieee.org]
% Please email me if you find bugs, or have suggestions or questions!

addpath('./Utils')

ImgZ = length(InImg);
mag = (PatchSize-1)/2;
OutImg = cell(NumFilters*ImgZ,1); 
cnt = 0;
for t = 1:ImgZ
    if(isreal(InImg{t}) == 0)
        im = InImg{t};
    else
        im = GetIGO(InImg{t});
    end
    [ImgX, ImgY, NumChls] = size(im);
    img = zeros(ImgX+PatchSize-1,ImgY+PatchSize-1, NumChls);
    img((mag+1):end-mag,(mag+1):end-mag,:) = im;    
    im_real = real(img);
    im_imag = imag(img);
    im = im2col_general(im_real,[PatchSize PatchSize]);
    im_t=im2col_general(im_imag,[PatchSize PatchSize]);
    im_t = 1i*im_t;
    im = im + im_t;
    
%     [ImgX, ImgY, NumChls] = size(InImg{t});
%     img = zeros(ImgX+PatchSize-1,ImgY+PatchSize-1, NumChls);
%     
%     img((mag+1):end-mag,(mag+1):end-mag,:) = InImg{t};    
%     im = im2col_general(img,[PatchSize PatchSize]); % collect all the patches of the ith image in a matrix
    im = bsxfun(@minus, im, mean(im)); % patch-mean removal 
    for j = 1:NumFilters
        cnt = cnt + 1;
        OutImg{cnt} = reshape(V(:,j)'*im,ImgX,ImgY);  % convolution output
    end
    InImg{t} = [];
end
OutImgIdx = kron(InImgIdx,ones(NumFilters,1)); 