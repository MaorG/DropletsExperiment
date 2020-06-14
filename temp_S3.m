%function em = temp

init

matlab_ver = 'michael'; % maor or michael
expMainTopic = '<main>'; % looks for expMainTopic in the experiment main file as the main experiment configuration properties; used when all configuration files are in one file
% note when all configuration files are in one file: in the main experiment
% configuration, specify the values for the fields 'load', 'prep', 'entities', 'analysis'
% and 'output' as '<load>', '<prep>', etc., instead of source files for
% these sections, <> corresponding to the topics in the main experiment
% file (conf here)

em = ExperimentManager(matlab_ver, expMainTopic);

conf = 'D:\Maor\DropletsExperiment\scripts\microscales_v2\microscale_fig_S3_pointcorr.csv'
em.configure(conf);


em.doLoad();
em.doPrep();
%em.doEntities();
%em.doAnalysis();
%em.doOutput();


