function fis = create_Fis()
    %% Fuzzy Variables, Membership Functions, Distributions 
    var = ["e" "de" "du"]; %E,dE=>9ΛΤ | dU=>7ΛΤ  
    mf = ["NV" "NL" "NM" "NS" "ZR" "PS" "PM" "PL" "PV"];
    dists = [-1 -1 -3/4 -1/2 -1/4 0 1/4 1/2 3/4 1 1; -1 -1 -2/3 -1/3 0 1/3 2/3 1 1 0 0];

    fis = mamfis;
    fis = addOutput(fis, [dists(1,1) dists(1,end)], "Name", var(end));
    
    for i=1:length(var)-1
        fis = addInput(fis, [dists(1,1), dists(1,end)], "Name", var(i));   
    end

    for i=1:length(var)-1
        for j=1:length(mf(1,:))
            fis = addMF(fis,var(i), "trimf", [dists(1,j) dists(1,j+1) dists(1,j+2)], "Name", mf(ceil(i/2),j));
        end
    end

    for j=1:length(mf(1,2:8))
            fis = addMF(fis,var(3), "trimf", [dists(2,j) dists(2,j+1) dists(2,j+2)], "Name", mf(ceil(1/2),j+1));
    end
    
    %% Read RuleBase
    fis = readfis("table.fis");
    % fis = readfis(".fis");

    %% Generate Figures
    figure;
    plotmf(fis, 'input' , 1);
    title('Membership Functions of e');

    figure;
    plotmf(fis, 'input' , 2);
    title('Membership Functions of de');

    figure;
    plotmf(fis, 'output' , 1);
    title('Membership Functions of du');
end    