function showTwoPointCorrDouble(data,parameters)

props = parseParams(parameters);
m = data.(props.CSRname);
n = data.(props.SFLname);

pixelSize = 0.16;

confidence = 0.01;

corrfun = m.corr;
r = m.r
r_csr = m.rCSR;
csr = m.csr;

sfl = n.csr;


csr_sorted = sort(csr,1);
csr_count = size(csr_sorted,1);
sfl_sorted = sort(sfl,1);
sfl_count = size(sfl_sorted,1);

margin = ceil(confidence*csr_count);


meanYcsr = median(csr_sorted,1);
meanYsfl = median(sfl_sorted,1);
errYscrbot = meanYcsr - csr_sorted(end - margin + 1,:);
errYcsrtop = csr_sorted(margin,:) - meanYcsr;
errYsflbot = meanYsfl - sfl_sorted(end - margin + 1,:);
errYsfltop = sfl_sorted(margin,:) - meanYsfl;


hold on
shadedErrorBar(r_csr(1:end),meanYcsr,[-errYscrbot;-errYcsrtop],'lineprops','k');
shadedErrorBar(r_csr(1:end),meanYsfl,[-errYsflbot;-errYsfltop],'lineprops','r');

%plot(r_csr*pixelSize, csr_sorted(margin,:),'r');
%plot(r_csr*pixelSize, csr_sorted(end-margin+1,:),'r');

 plot(r, corrfun,'k-', 'LineWidth', 2);

if false && (isfield(m, 'randomExample'))
    plot(r_csr, m.randomExample,'k-', 'LineWidth', 2);
end
 
 
xlim([0,100]);
set(gca,'LineWidth',2)
set(gca,'FontSize',14)
box on
xlabel('distance [\mum]')
ylabel('G_{11}')
%set(gca,'yscale','log')
end

function props = parseParams(v)
% default:
props = struct(...
    'CSRname','pc_r',...
    'SFLname','pc_s' ...
    );

for i = 1:numel(v)
    
    if (strcmp(v{i}, 'CSRname'))
        props.CSRname = v{i+1};
    elseif (strcmp(v{i}, 'SFLname'))
        props.SFLname = v{i+1};
    end
end

end