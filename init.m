function init
addpath(genpath(pwd));
return;
addpath([pwd,'/parser']);
addpath([pwd,'/ExperimentManager']);
addpath([pwd,'/DataManager']);
addpath([pwd,'/EntityManager']);
addpath([pwd,'/AnalysisManager']);
addpath([pwd,'/prepFuncs']);
addpath([pwd,'/entityFuncs']);
addpath([pwd,'/analysisFuncs']);
addpath([pwd,'/NDResultTable']);
addpath([pwd,'/OutputManager']);
addpath([pwd,'/outputFuncs']);
addpath(genpath([pwd,'/utils']));
end