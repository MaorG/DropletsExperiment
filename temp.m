function em = temp

init

em = ExperimentManager();
em.configure();

em.doLoad();
em.doPrep();
em.doEntities();
em.doAnalysis();
em.doOutput();

end

