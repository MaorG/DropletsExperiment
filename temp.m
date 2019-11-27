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



conf = 'D:\Maor\DropletsExperiment\scripts\microbiota_paper_config_for_pipeline_old_exp.csv'

%conf = 'D:\Maor\DropletsExperiment\scripts\microbiota_paper_config_for_pipeline_control.csv'

conf = '\\QNAP01\LongTerm\Yana\29.10.19\survival101.csv'
conf = '\\QNAP01\LongTerm\Maor\seg-exp\test_seg.csv';
conf = 'D:\Maor\DropletsExperiment\scripts\microbiota_control_figure_kfunc.csv'
conf = 'D:\Maor\DropletsExperiment\scripts\microbiota_exp_figure_aggr_size_dist.csv'

conf = 'D:\Maor\DropletsExperiment\scripts\microbiota_control_figure_coverage_aggr.csv'
conf = 'D:\Maor\DropletsExperiment\scripts\microbiota_exp_figure_point_corr_microbiota.csv'

conf = 'D:\Maor\DropletsExperiment\scripts\microbiota_exp_figure_aggr_size_dist_01.csv'

conf = 'D:\Maor\DropletsExperiment\scripts\microbiota_old_exp_NN.csv'
conf = 'D:\Maor\DropletsExperiment\scripts\microbiota_classification.csv';

conf = 'D:\Maor\DropletsExperiment\scripts\microbiota_v3_comparisons.csv'
conf = 'D:\Maor\DropletsExperiment\scripts\microbiota_v3_aggr_size.csv';


conf = 'D:\Maor\DropletsExperiment\scripts\microbiota_windows.csv'
em.configure(conf);

em.doLoad();
em.doPrep();
em.doEntities();
em.doAnalysis();
em.doOutput();

%end

