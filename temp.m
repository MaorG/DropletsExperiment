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


conf = 'C:\school2\matlab\DropletExperiment\DropletsExperiment\scripts\dopletSeg\dropSeg102.csv'
%conf = 'D:\Maor\DropletsExperiment\scripts\dopletSeg\dropSeg101.csv'
conf = 'D:\Maor\DropletsExperiment\scripts\microscale\microscale_coverage_fig3.csv'
conf = 'D:\Maor\DropletsExperiment\scripts\microscale\microbiota_histories_2.csv';
conf = 'D:\Maor\DropletsExperiment\scripts\microscale\microscale_coverage_aggr_size_fig_8_wells.csv'
conf = '\\QNAP01\LongTerm\Maor\microbiota v3\wells\load_seg_2.csv'
conf = 'D:\Maor\DropletsExperiment\scripts\microscale\microscale_coverage_aggr_size_fig_4BC.csv'
em.configure(conf);

em.doLoad();
em.doPrep();
em.doEntities();
em.doAnalysis();
em.doOutput();

%end

