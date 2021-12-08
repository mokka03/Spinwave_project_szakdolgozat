clear all, close all;

%% Magnonic Crystals: From Simple Models toward Applications Jaros?awW. K?os and Maciej Krawczyk (pg. 288)

% set magnetization directin here:
oop = 1;    % (1: out-of-plane, 0: in-plane)

save_ = 0;  % if ==1 save figures
save_path = "figures/";

%% constants
mu0 = 4*pi*1e-7;
if oop
    theta = 0;  % H0 angle, 0 if oop
else
    theta = pi/2;
end

d = 70e-9;      % film thickness
if oop
    Bext = 300e-3;   % applied field in T
else
    Bext = 30e-3;   % applied field in T
end
%% material parameters

Ms_YIG = 1.4e5;
A_YIG = 3.65E-12;

Bext = 283e-3;

Ms0 = Ms_YIG;
A = A_YIG;
gamma = 2*pi*28e9; % Hz/T gamma*mu0=2.21e5 used in OOMMF

%%
close all;
figure
load('Ms_out2.mat');
Ms_ = Ms_out(1,:);
% Ms_ = [130670:1000:145670];
WL_ = [500:1:50000]*1e-9;

for Ms = Ms_
    for WL = WL_
        if oop
            H0 = Bext/mu0-Ms; %% effective field
        else
            H0 = Bext/mu0; %% effective field
        end
        
        kxx = 2*pi/WL;
        omegaM = gamma*mu0*Ms;
        omegaHx = gamma*mu0*(H0+2*A/(mu0*Ms).*kxx.^2);
        Px = 1-(1-exp(-abs(kxx)*d))./(abs(kxx)*d);
        Phi2 = pi/2*0;
        omegax = sqrt(omegaHx.*(omegaHx+omegaM*(Px+sin(theta)^2*(1-Px.*(1+cos(Phi2).^2)+omegaM./omegaHx.*(Px.*(1-Px).*sin(Phi2).^2)))));
        if WL == WL_(1)
            f = omegax/2/pi;
        else
            f(end+1) = omegax/2/pi;
        end
        
    end
    plot(WL_*1e6,f*1e-9)
    hold on;
    [p,~,mu] = polyfit(f,WL_,50);
    y1 = polyval(p,3.3423e9,[],mu);
    if Ms == Ms_(1)
        WL_levels = y1;
    else
        WL_levels(end+1) = y1;
    end

    clear f;
end
plot(WL_*1e6,ones(size(WL_))*3.3423);
hold off;
title("Dependence of the dispersion curve upon external field");
xlabel("Wavelength \mum");
ylabel("f [Hz]");

% if save_
%     save_png = strcat(save_path,"MsChange_WL_f.png");
%     save_fig = strcat(save_path,"MsChange_WL_f.fig");
%     saveas(gcf,save_png)
%     saveas(gcf,save_fig)
% end

%%
figure
plotx = Ms_*1e-3;
ploty = WL_levels*1e6;
plot(plotx,ploty)
title({['Dependence of wavelength upon'] ['saturation magnetization']});
xlabel("Saturation magnetization [kA/m]");
ylabel("Wavelength [\mum]");
xlim([plotx(1) plotx(end)]);

if save_
    save_png = strcat(save_path,"MsChange_Ms_WL.png");
    save_fig = strcat(save_path,"MsChange_Ms_WL.fig");
    saveas(gcf,save_png)
    saveas(gcf,save_fig)
end
Ms_WL_levels = WL_levels;
% save('MsChange_WL_levels_130670_to_145670_step500.mat','Ms_WL_levels')