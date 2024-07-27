function fis = createFis()
    %% Fuzzy Variables, Membership Functions, Distributions 
    var = ["dv" "dh" "th" "dth"];
    mf = ["S" "M" "L"; "N" "ZE" "P"];
    dists = [0 0 0.5 1 1 ; 0 0 0.5 1 1 ; -180 -180 0 180 180 ; -130 -130 0 130 130];

    fis = mamfis;
    fis = addOutput(fis, [dists(end,1) dists(end,5)], "Name", var(end));

    for i=1:length(var)-1
        fis = addInput(fis, [dists(i,1), dists(i,5)], "Name", var(i));   
    end

    for i=1:length(var)
        for j=1:length(mf(1,:))
            fis = addMF(fis,var(i), "trimf", [dists(i,j) dists(i,j+1) dists(i,j+2)], "Name", mf(ceil(i/2),j));
        end
    end
    
    %% Read RuleBase
    % fis = readfis("initial_cntrl.fis");
    fis = readfis("modified_cntrl.fis");

    %% Generate Figures
    figure;
    plotmf(fis, 'input' , 1);
    title('Membership Functions of dV');

    figure;
    plotmf(fis, 'input' , 2);
    title('Membership Functions of dH');

    figure;
    plotmf(fis, 'input' , 3);
    title('Membership Functions of Theta');

    figure;
    plotmf(fis, 'output' , 1);
    title('Membership Functions of dTheta');
end    