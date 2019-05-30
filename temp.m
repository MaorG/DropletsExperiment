%function em = temp

init

em = ExperimentManager();

conf = '\\QNAP01\LongTerm\Maor\14.5.19 p130519mix1\exp_mix_201_manual.csv'
conf = '\\QNAP01\LongTerm\Maor\14.5.19 p130519mix1\exp_mix_201_phase2.csv'
conf = '\\QNAP01\LongTerm\Maor\14.5.19 p130519mix1\exp_mix_201_phase3.csv'
conf = '\\QNAP01\LongTerm\Maor\14.5.19 p130519mix1\exp_mix_201_manual_second_dry.csv'
conf = 'C:\school\DropletsExperiment\configurations\memory 101\exp_memory101.csv'
conf = 'C:\school\DropletsExperiment\configurations\memory 101\exp_memory101 - phase2.csv'
conf = 'C:\school\DropletsExperiment\configurations\15.5.19 p130519memory2\exp_memory101 - phase2.csv'
conf = 'C:\school\DropletsExperiment\configurations\15.5.19 p130519memory2\exp_memory101 - t3 seg.csv'

conf = 'C:\school\DropletsExperiment\configurations\15.5.19 p130519memory2 - reg\exp_memory101 - phase3.csv'
em.configure(conf);

em.doLoad();
em.doPrep();
em.doEntities();
em.doAnalysis();
em.doOutput();

%end

