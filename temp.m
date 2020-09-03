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

%conf = 'D:\Maor\DropletsExperiment\scripts\microscale\microscale_coverage_aggr_size_fig_8.csv'

conf = 'D:\Maor\AntiLiveDead\scripts\MSW_antibiotics_101.csv'
conf = 'D:\Maor\AntiLiveDead\scripts\bulk_antibiotics_101.csv'

conf = 'D:\Maor\AntiLiveDead\scripts\bulk_antibiotics_09072020.csv'

conf = 'D:\Maor\DropletsExperiment\scripts\agar\seg_try01.csv'
conf = 'D:\Maor\DropletsExperiment\scripts\agar\seg_try02.csv'


em.configure(conf);


em.doLoad();
em.doPrep();
em.doEntities();
em.doAnalysis();
em.doOutput();

%end

