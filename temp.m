%function em = temp

init

em = ExperimentManager();

conf = '\\qnap01\LongTerm\Maor\droplets\bioreporter 31.3.19\conf time handling\exp_biorep_31.3.csv'
conf = '\\qnap01\LongTerm\Michael\drops\alexa seg\exp_alexa_auto.csv';
conf = '\\qnap01\LongTerm\Michael\drops\exp alexa_22.4.19\exp_alexa_auto.csv';
conf = '\\qnap01\LongTerm\Michael\drops\paper\pipeline conf\expConfig.csv';

%conf = '\\qnap01\LongTerm\Michael\drops\registered\exp_memory101 - phase2 - registration.csv'
conf = '\\qnap01\LongTerm\Michael\drops\registered\downd\exp_memory101 - phase3.csv';


em.configure(conf);

em.doLoad();
em.doPrep();
em.doEntities();
em.doAnalysis();
em.doOutput();

%end

