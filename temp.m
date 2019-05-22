%function em = temp

init

em = ExperimentManager();

% conf = '\\QNAP01\LongTerm\Maor\14.5.19 p130519mix1\exp_mix_201_manual.csv'
% conf = '\\QNAP01\LongTerm\Maor\14.5.19 p130519mix1\exp_mix_201_phase2.csv'
% conf = '\\QNAP01\LongTerm\Maor\14.5.19 p130519mix1\exp_mix_201_phase3.csv'
% 
% conf = '\\QNAP01\LongTerm\Maor\14.5.19 p130519mix1\exp_mix_201_manual_second_dry.csv'

conf = '\\QNAP01\LongTerm\Maor\15.5.19 p130519memory2\exp_memory101_phase1.csv'

em.configure(conf);

em.doLoad();
em.doPrep();
em.doEntities();
em.doAnalysis();
em.doOutput();

%end

