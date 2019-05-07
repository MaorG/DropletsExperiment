%function em = temp

init

em = ExperimentManager();

conf = '\\QNAP01\LongTerm\Maor\droplets\alexa_auto_seg\exp_alexa_auto.csv'
conf = '\\QNAP01\LongTerm\Maor\5.5.19\exp_mix101_after_user_input.csv'

em.configure(conf);

em.doLoad();
em.doPrep();
em.doEntities();
em.doAnalysis();
em.doOutput();

%end

