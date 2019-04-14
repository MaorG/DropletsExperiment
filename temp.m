function em = temp

init

em = ExperimentManager();

conf = '\\qnap01\LongTerm\Maor\droplets\bioreporter 31.3.19\conf time handling\exp_biorep_31.3.csv'
em.configure(conf);

em.doLoad();
em.doPrep();
em.doEntities();
em.doAnalysis();
em.doOutput();

end

