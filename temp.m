function em = temp

init

em = ExperimentManager();

em.configure();

%em.doWork();
em.doLoad();
em.doPrep();
%saveFields = {'DropMaskName', 'CellMaskName', 'GName', 'RName', 'repeat', 'time', 'well', 'R_minus_bg', 'G_minus_bg'};
saveFields = {};
%em.savePrep(saveFields);

end

