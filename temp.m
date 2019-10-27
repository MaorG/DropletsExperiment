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

conf ='C:\school\papers\microbiota\point\pointpatterns.csv';
conf ='C:\school\papers\microbiota\analysis\microbiota_paper_config_for_pipeline.csv';
conf ='C:\school\papers\microbiota\analysis\microbiota_paper_config_for_pipeline.csv';
conf ='C:\school\papers\microbiota\analysis\microbiota_paper_config_for_pipeline_old_exp.csv';


conf = 'D:\Maor\DropletsExperiment\scripts\microbiota_paper_config_for_pipeline_control.csv'

conf = 'D:\Maor\DropletsExperiment\scripts\microbiota_paper_config_for_pipeline_old_exp.csv'
em.configure(conf);

em.doLoad();
em.doPrep();
em.doEntities();
em.doAnalysis();
em.doOutput();

%end

