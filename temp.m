function em = temp

init

em = ExperimentManager();

conf = 'C:\school\DropletsExperiment\configurations\biorep 31.3.19\exp_biorep_31.3.csv'
em.configure(conf);

em.doLoad();
em.doPrep();
em.doEntities();
em.doAnalysis();
em.doOutput();

end

