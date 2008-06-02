function model = gpReadFromFID(FID, varargin)

% GPREADFROMFID Load from a FID produced by the C++ implementation.
% FORMAT
% DESC loads in from a file stream the data format produced by the
% C++ GP implementation.
% ARG FID : the file ID from where the data is loaded.
% RETURN model : the model loaded in from the file.
%
% COPYRIGHT : Neil D. Lawrence, 2005, 2006, 2008
%
% SEEALSO : gpReadFromFile

% GP

numData = readIntFromFID(FID, 'numData');
dataDim = readIntFromFID(FID, 'outputDim');
inputDim = readIntFromFID(FID, 'inputDim');
sparseApprox = readIntFromFID(FID, 'sparseApproximation');
numActive = readIntFromFID(FID, 'numActive');
if sparseApprox
  beta = modelReadFromFID(FID);
  beta = beta(1, 1);
end

learnScale = readBoolFromFID(FID, 'learnScale');
learnBias = readBoolFromFID(FID, 'learnBias');
scale = modelReadFromFID(FID);
bias = modelReadFromFID(FID);

kern = modelReadFromFID(FID);
noise = modelReadFromFID(FID);

if sparseApprox
  X_u = modelReadFromFID(FID);
end

X = varargin{1};
y = varargin{2};
% X = zeros(numData, inputDim);
% y = zeros(numData, dataDim);

warning('Noise model is ignored');

switch sparseApprox
 case 0
  approxType = 'ftc';
 case 1
  approxType = 'dtc';
 case 2
  approxType = 'fitc';
 case 3
  approxType = 'pitc';
end
options = gpOptions(approxType);
options.numActive = numActive;
options.kern = kern;
model = gpCreate(inputDim, size(y, 2), X, y, options);
model.X = X;
model.X_u = X_u;
if sparseApprox
  model.beta = beta;
end
model.scale = scale;
model.bias = bias;
model.m = gpComputeM(model);

% This forces kernel computation.
initParams = gpExtractParam(model);
model = gpExpandParam(model, initParams);
