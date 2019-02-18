function temp

init

em = ExperimentManager();

em.configure();

em.doLoad();

%todo michael: remove, just showing you how to view the state of things
disp(em.dm.allData(1));

em.doPrep();

disp(em.dm.allData(1));

end

