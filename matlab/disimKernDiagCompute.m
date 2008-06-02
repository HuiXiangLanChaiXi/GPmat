function k = disimKernDiagCompute(kern, t)

% DISIMKERNDIAGCOMPUTE Compute diagonal of DISIM kernel.
% FORMAT
% DESC computes the diagonal of the kernel matrix for the driven input
%  single input motif kernel given a design matrix of inputs.
% ARG kern : the kernel structure for which the matrix is computed.
% ARG t : input data matrix in the form of a design matrix.
% RETURN k : a vector containing the diagonal of the kernel matrix
% computed at the given points.
%
% SEEALSO : disimKernParamInit, kernDiagCompute, kernCreate, disimKernCompute
%
% COPYRIGHT : Neil D. Lawrence, 2006
%
% COPYRIGHT : Antti Honkela, 2007

% KERN

if size(t, 2) > 1 
  error('Input can only have one column');
end

l = sqrt(2/kern.inverseWidth);
t = t;
delta = kern.di_decay;
D = kern.decay;
halfLD = 0.5*l*D;
halfLDelta = 0.5*l*delta;

lnPart1 = lnDiffErfs(halfLDelta - t/l, ...
				halfLDelta);
lnPart2 = lnDiffErfs(halfLDelta + t/l, ...
				halfLDelta);

lnCommon = halfLDelta .^ 2 -(D+delta)*t - log(2*delta) - log(D-delta);
lnFact1a = (D - delta) * t + log(D + delta) - log(D^2 - delta^2);
lnFact1b = log(2*delta) - log(D^2 - delta^2);
lnFact2 = (D+delta)*t - log(D + delta);

h = exp(lnCommon + lnFact1a + lnPart1) ...
    - exp(lnCommon + lnFact1b + lnPart1) ...
    + exp(lnCommon + lnFact2 + lnPart2);

lnPart1p = lnDiffErfs(halfLD - t/l, ...
				 halfLD);
lnPart2p = lnDiffErfs(halfLD + t/l, ...
				 halfLD);

lnCommonp = halfLD.^2 - 2*D*t - log(2*D) - log(delta^2 - D^2);
lnFact1ap = log(D + delta) - log(delta - D);
lnFact1bp = log(2*D) + (D-delta)*t - log(delta - D);
lnFact2p = 2*D*t;

hp = exp(lnCommonp + lnFact1ap + lnPart1p) ...
     - exp(lnCommonp + lnFact1bp + lnPart1p) ...
     + exp(lnCommonp + lnFact2p + lnPart2p);

k = 2*real(h+hp);
k = 0.5*k*sqrt(pi)*l;
k = kern.di_variance*kern.variance*k;
