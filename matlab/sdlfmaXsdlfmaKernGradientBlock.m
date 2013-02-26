function [g1, g2, g3] = sdlfmaXsdlfmaKernGradientBlock(lfmKern1, lfmKern2, ...
    t1, t2, kyy, kyv, kvy, kvv, i, j, generalConst, generalConstGrad, ...
    covGrad)

% SDLFMAXSDLFMAKERNGRADIENTBLOCK Gradients of the parameters in block i,j
% FORMAT
% DESC computes the kernel parameters gradients for the SDLFM kernel 
% function in the block specified at indeces i,j. It assumes the 
% computation for functions that both systems describe accelerations.
% ARG lfmKern1 : structure containing parameters for the system 1
% ARG lfmKern2 : structure containing parameters for the system 2
% ARG t1 : times at which the system 1 is evaluated
% ARG t2 : times at which the system 2 is evaluated
% ARG kyy : covariance for the initial conditions between position 1 and
% position 2 at block i,j
% ARG kyv : covariance for the initial conditions between position 1 and
% velocity 2 at block i,j
% ARG kvy : covariance for the initial conditions between velocity 1 and
% position 2 at block i,j
% ARG kvv : covariance for the initial conditions between velocity 1 and
% velocity 2 at block i,j
% ARG i : interval to be evaluated for system 1
% ARG j : interval to be evaluated for system 2
% ARG generalConstant : constants evaluated with sdlfmKernComputeConstant.m
% ARG generalConstGrad : derivatives of the constants computed with
% sdlfmKernGradientConstant.m
% ARG covGrad : partial derivatives of the objective function wrt portion
% of the kernel matrix in block i,j
% RETURN g1 : gradients of parameters for the system 1
% RETURN g2 : gradients of parameters for the system 2
% RETURN g3 : gradients of switching points
%
% COPYRIGHT : Mauricio A. Alvarez, 2010.

% SHEFFIELDML


if nargin<11
    j = i;
    generalConst = [];
end

g3 = [];

% Compute derivatives of the mean terms with respect to the parameters

[g1Mean, g2Mean, gsp1Mean, gsp2Mean] = sdlfmKernGradientMean(lfmKern1(1), ...
    lfmKern2(1), t1, t2, kyy, kyv, kvy, kvv, covGrad, {'sdlfma','sdlfma'}, ...
    {'sdlfmj', 'sdlfmj'});

if i==j
    [g1, g2, g3t] = sdlfmXsdlfmKernGradientBlockIEJ(lfmKern1, lfmKern2, t1, ...
        t2, covGrad, g1Mean, g2Mean, gsp1Mean, gsp2Mean, {'lfma', 'lfma'}, ...
        {'lfmj', 'lfma'}, {'lfmj', 'lfma'});
    g3(i) = g3t;
else
    if i>j
        [g1, g2, g3] = sdlfmaXsdlfmaKernGradientBlockIGJ(lfmKern1, lfmKern2, ...
            t1, t2, i, j, generalConst, generalConstGrad, covGrad, g1Mean, ...
            g2Mean, gsp1Mean, gsp2Mean, 'sdlfma', 'sdlfmj', 'lfmaXlfm', ...
            'lfmaXlfmv', {'lfmaXlfmv', 'lfmjXlfm'}, {'lfmaXlfma', 'lfmjXlfmv'});
    else
        [g1, g2, g3] = sdlfmaXsdlfmKernGradientBlockILJ(lfmKern1, lfmKern2, ...
            t1, t2, i, j, generalConst, generalConstGrad, covGrad, g1Mean, ...
            g2Mean, gsp1Mean, gsp2Mean, 'sdlfma', 'sdlfmj', 'lfmaXlfm', ...
            'lfmaXlfmv',{'lfmjXlfm', 'lfmaXlfmv'}, {'lfmjXlfmv', 'lfmaXlfma'});
    end
end
