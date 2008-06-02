function kernRet = multiKernTest(kernType, tieParams);

% MULTIKERNTEST Run some tests on the multiple output block kernel.
% FORMAT
% DESC runs some tests on the specified kernel to ensure it is
% correctly implemented.
% ARG kernType : type of kernel to test. Must be a cell structure
% whose first entry is 'multi', for example
% {'multi', 'rbf', 'sim', 'sim'}.
% RETURN kern : the kernel that was generated for the tests.
%
% DESC runs some tests on the specified kernel to ensure it is
% correctly implemented.
% ARG kern : kernel structure containing kernel to be tested.
% RETURN kern : the kernel structure as it was used in the tests.
% 
% DESC runs some tests on the specified kernel to ensure it is
% correctly implemented, some of the parameters of the different
% kernels forming the multiKern are forced to be the same. These
% are specified by TIEPARAMS.
% ARG kernType : type of kernel to test. Must be a cell structure
% whose first entry is 'multi', for example
% {'multi', 'rbf', 'sim', 'sim'}.
% ARG tieParams : some parameters must be the same for the multiple
% output kernel to make sense. For example, in the RBF and SIM
% case, the inverse widths of the kernels must be the same. If the
% kernel type is {'multi', 'rbf', 'sim', 'sim'} then this can be
% forced by specifying TIEPARAMS as {[1 4 7]}. See MODELTIEPARAM
% for more details on the form of this argument.
% RETURN kern : the kernel that was generated for the tests.
% 
% SEEALSO : multiKernParamInit, modelTieParam
%
% COPYRIGHT : Neil D. Lawrence, 2006

% KERN

numData = 20;
numIn = 1;

if ~iscell(kernType) & ~isstruct(kernType)
  error('Input type to multiKernTest should be a struct or a cell array.');
end
if iscell(kernType) & ~strcmp(kernType{1}, 'multi')
  error('Input kern type to multi kern test should have first entry ''multi''.')
end
  
% Generate some x positions.
x = linspace(-1, 1, numData)'; %randn(numData, numIn);
x2 = randn(numData/2, numIn);
if isstruct(kernType)
  kern = kernType;
else
  kern = kernCreate(x, kernType);
  if nargin>1
    kern = modelTieParam(kern, tieParams);
  end
  % Set the parameters randomly.
  params = kernExtractParam(kern);
  params = randn(size(params))./sqrt(randn(size(params)).^2);
  kern = kernExpandParam(kern, params);
end
 
% covGrad = randn(numData*kern.numBlocks);
% covGrad = covGrad*covGrad';
covGrad = ones(numData*kern.numBlocks);
epsilon = 1e-6;
params = kernExtractParam(kern);
origParams = params;
for i = 1:length(params);
  params = origParams;
  params(i) = origParams(i) + epsilon;
  kern = kernExpandParam(kern, params);
  Lplus(i) = full(sum(sum(kernCompute(kern, x).*covGrad)));
  params(i) = origParams(i) - epsilon;
  kern = kernExpandParam(kern, params);
  Lminus(i) = full(sum(sum(kernCompute(kern, x).*covGrad)));
end
params = origParams;
kern = kernExpandParam(kern, params);
[void, names] = kernExtractParam(kern);
gLDiff = .5*(Lplus - Lminus)/epsilon;
g = kernGradient(kern, x, covGrad);

paramMaxDiff = max(max(abs(gLDiff-g)));
if paramMaxDiff > 2*epsilon
  l = 0;
  for i = 1:length(names)
    if l < length(names{i})
      l = length(names{i});
    end
  end
  
  fprintf([char(repmat(32, 1, l)) '\tanalytic   diffs     delta\n']);
  for i = 1:length(names)
    spaceLen = l - length(names{i});
    space = char(repmat(32, 1, spaceLen));
    fprintf([space names{i} ':\t%4.6f\t%4.6f\t%4.6f\n'], ...
            g(i), gLDiff(i), gLDiff(i) - g(i));
  end
end

testX=0;
if testX
  Lplus = zeros(size(x));
  Lminus = zeros(size(x));
  gx = zeros(size(x));
  origX = x;
  for i = 1:size(x, 1)
    for j = 1:size(x, 2)
      x = origX;
      x(i, j) = origX(i, j) + epsilon;
      K = kernCompute(kern, x);
      Lplus(i, j) =  full(sum(sum(K)));
      LplusDiag(i, j) = full(trace(K));
      x(i, j) = origX(i, j) - epsilon;
      K = kernCompute(kern, x);
      Lminus(i, j) = full(sum(sum(K)));
      LminusDiag(i, j) = full(trace(K));
    end
    x = origX;
    gx(i, :) = 2*sum(kernGradX(kern, x(i, :), x), 1);
    gxDiag(i, :) = kernDiagGradX(kern, x(i, :));
  end
  
  gXDiff = .5*(Lplus - Lminus)/epsilon;
  xMaxDiff = max(max(abs(gx-gXDiff)));
  
  if xMaxDiff > 2*epsilon
    fprintf('gX\n')
    disp(gx)
    fprintf('gXDiff\n')
    disp(gXDiff)
  end
  
  gXDiagDiff = .5*(LplusDiag - LminusDiag)/epsilon;
  xDiagMaxDiff = max(max(abs(gxDiag-gXDiagDiff)));
  
  if xDiagMaxDiff > 2*epsilon
    fprintf('gxDiag\n')
    disp(gxDiag)
    fprintf('gXDiagDiff\n')
    disp(gXDiagDiff)
  end
end
K = kernCompute(kern, x);
traceK =  full(trace(K));
traceK2 = full(sum(kernDiagCompute(kern, x)));
traceDiff = traceK - traceK2; 

% covGrad = randn(numData*kern.numBlocks, numData/2*kern.numBlocks);
covGrad = ones(numData*kern.numBlocks, numData/2*kern.numBlocks);
epsilon = 1e-6;
% params = kernExtractParam(kern);
% origParams = params;
Lplus = zeros(size(params));
Lminus = zeros(size(params));
for i = 1:length(params);
  params = origParams;
  params(i) = origParams(i) + epsilon;
  kern = kernExpandParam(kern, params);
  Lplus(i) = full(sum(sum(covGrad.*kernCompute(kern, x, x2))));
  params(i) = origParams(i) - epsilon;
  kern = kernExpandParam(kern, params);
  Lminus(i) = full(sum(sum(covGrad.*kernCompute(kern, x, x2))));
end
params = origParams;
kern = kernExpandParam(kern, params);
[void, names] = kernExtractParam(kern);
gL2Diff = .5*(Lplus - Lminus)/epsilon;
g = kernGradient(kern, x, x2, covGrad);

param2MaxDiff = max(max(abs(gL2Diff-g)));
if param2MaxDiff > 2*epsilon
  l = 0;
  for i = 1:length(names)
    if l < length(names{i})
      l = length(names{i});
    end
  end
  
  fprintf([char(repmat(32, 1, l)) '\tanalytic   diffs     delta\n']);
  for i = 1:length(names)
    spaceLen = l - length(names{i});
    space = char(repmat(32, 1, spaceLen));
    fprintf([space names{i} ':\t%4.6f\t%4.6f\t%4.6f\n'], ...
            g(i), gL2Diff(i), gL2Diff(i) - g(i));
  end
end


fprintf('Trace max diff: %2.6f.\n', traceDiff);
fprintf('Param max diff: %2.6f.\n', paramMaxDiff)
fprintf('Param X2 max diff: %2.6f.\n', param2MaxDiff)
if testX
  fprintf('X max diff: %2.6f.\n', xMaxDiff)
  fprintf('XDiag max diff: %2.6f.\n', xDiagMaxDiff)
end
fprintf('\n');

if nargout > 0
  kernRet = kern;
else
  kernDisplay(kern);
end
