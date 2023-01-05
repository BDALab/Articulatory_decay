function [out] = articulatory_decay(x,fs,n_th_seg, show_graph)

% This function returns the resonant frequencies attenuations RFA1, RFA2,
% number of local maxima N_peaks and frequencies of formants F1, F2.

% INPUT
% x ... vector of samples
% fs ... sampling frequency

% SETUP (optional)
% n_th_seg = any value  -> observe features in n'th segment
% n_th_seg = 0          -> parametrise all segments (default)
%
% show_graph = true     -> plot 
% show_graph = false    -> no plot (default) 

% OUTPUT
% out.RFA1 ... vertical distance in the LPC spectra between the 
%               second formant and the local minima of the valley before
% out.RFA2 ... vertical distance in the LPC spectra between the 
%               second formant and the local minima of the valley after 
% out.N_peaks ... number of local maxima in the LPC spectrum
% out.F1 ... frequency of the frist formant
% out.F2 ... frequency of the second fromant

%% setup

if nargin < 3
    n_th_seg = 0;
end
if nargin < 4
    show_graph = false;
end

addpath(genpath([pwd '\external\' 'Praat']))

%% variables
winlen = 0.025; 
winover = 0.010;

min_F0 = 75;
max_F0 = 400;

p = 12;

%% take first audio channel

x = x(:,1);

%% resample to 16 kHz
fs_new = 16000;
if not(fs == fs_new)
    [Numer, Denom] = rat(fs_new/fs);
    x = resample(x, Numer, Denom);
end

%% remove offset
x = detrend(x);

%% Segmentation
X = segmentation(x, winlen*fs_new, winover*fs_new);
[n_rows,n_cols] = size(X);

%% Voicing (F0 misplace)
vo = [praat_voicing(x, fs_new, min_F0, max_F0, n_cols)]';

%% energy
energy = sum(X.^2);
energy = energy/max(energy);

if not(n_th_seg == 0)
    X = X(:,n_th_seg);
    [n_rows,n_cols] = size(X);
end

%% cyclus
voicing = zeros(1,n_cols);
RFA_1_vector = zeros(1,n_cols);
RFA_2_vector = zeros(1,n_cols);
n_maxima = zeros(1,n_cols);
F1_vector = zeros(1,n_cols);
F2_vector = zeros(1,n_cols);

for c = 1:n_cols

    %% take one segment
    S = X(:,c);
    
    %% LPC
    a = lpc(S, p);
    a = a.';
    
    z_vector = roots(a);
    
    z_plus = z_vector(imag(z_vector) > 0);
    f_poles = (angle(z_plus)/(2*pi))*fs_new;
    formants = sort(f_poles);
    
    %% transfer function
    
    f=(1:1:fs_new/2);
    Ts=1/fs_new;            %sampling period
    fs_d=Ts.*f;         %discretization of frequency range
    Ws=2.*pi.*fs_d;     %discrete angular frequency
    z=exp(1i.*Ws);
    
    b_filter = [zeros(1,length(a)-1) 1];
    a_filter = flip(a)';
    
    denominator = 0;
    for i = 0:(length(a)-1)
        denominator = denominator + (z.^-i)*a(i+1);
    end
    
    H = 20*log10(abs(1./denominator));
    
    %% investigate the curve
    
    [pks_max,loc_max] = findpeaks(H);
    [pks_min,loc_min] = findpeaks(-H);
    pks_min = -pks_min;
    
    voiced = 1;

    if formants(2) > 3000
        if formants(1) > 1000 && formants(1) < 2000
            formants = [500 formants'];
        else
            voiced = 0;
        end
    elseif formants(1) > 1000
            formants = [500 formants'];
    end

    idx_f_formant = zeros(1,length(formants));
    for k = 1:length(formants)
    [~, idx_formant_iter] = min(abs(f-formants(k)));
    idx_f_formant(k) = idx_formant_iter;
    end

    if isempty(loc_min)
        voiced = 0;
        voicing(c) = voiced;
        RFA_1_vector(c) = NaN;
        if not(n_th_seg == 0)
            disp('no local minimum exists')
        end
        continue
    else
        if voiced == 1 && min(loc_min) < 4000
            for m = 1:length(loc_min)
                if loc_min(m) > idx_f_formant(2) && ...
                   loc_min(m) < idx_f_formant(3)
                    F2_min = round(loc_min(m));
                        if H(F2_min) > H(idx_f_formant(2))
                            F2_min = idx_f_formant(2);
                        end
                    break
                else
                    if H(idx_f_formant(3)) < H(idx_f_formant(2))
                        F2_min = round...
                            ((idx_f_formant(2)+idx_f_formant(3))/2);
                    else
                        F2_min = idx_f_formant(2);
                    end
                end
            end
        else
            voiced = 0;
        end
    end

    if voiced == 0
        RFA_1_vector(c) = NaN;
        voicing(c) = voiced;
        continue
    end

    if  voiced == 1 && length(formants) > 2 ...
        && (H(idx_f_formant(1)) > H(idx_f_formant(3)))
            voiced = 1;        
    else
            voiced = 0;
    end
    
    if  voiced == 1 && length(formants) > 3
        if sum(H(idx_f_formant(1:3))) > sum(H(idx_f_formant(4:end)))
            voiced = 1;
        else
            voiced = 0;
        end
    end
    
    if  voiced == 1 && length(formants) > 4 
        if min(H(idx_f_formant(1:3))) > max(H(idx_f_formant(5:end)))
            voiced = 1;
        else
            voiced = 0;
        end
    end
        
    % F0 check
    if not(n_th_seg == 0)
        if vo(n_th_seg) == 1
            voicing(c) = voiced;
        else
            voiced = 0;
            voicing(c) = voiced;
        end
    else
        if vo(c) == 1
            voicing(c) = voiced;
        else
            voiced = 0;
            voicing(c) = voiced;
        end
    end

    %% RFA 
    F1 = idx_f_formant(1);
    F2 = idx_f_formant(2);

    for m = 1:length(loc_min)
        if loc_min(m) > idx_f_formant(1) && ...
           loc_min(m) < idx_f_formant(2)
            F1_min = round(loc_min(m));
            if H(F1_min) > H(idx_f_formant(2))
                F1_min = F2;
            end
            break
        elseif H(idx_f_formant(1)) < H(idx_f_formant(2))
            F1_min = round((idx_f_formant(1)+idx_f_formant(2))/2);
        else
            F1_min = F2;
        end
    end
    
    RFA_1_vector(c) = H(F2) - H(F1_min);
    RFA_2_vector(c) = H(F2) - H(F2_min);
    

    %% n of local maxima
    n_maxima(c) = length(loc_max);

    %% formants
    F1_vector(c) = F1;
    F2_vector(c) = F2;
    
end

RFA_1_voiced = RFA_1_vector(voicing==1);
RFA_2_voiced = RFA_2_vector(voicing==1);
n_maxima_voiced = n_maxima(voicing==1);

out.RFA1 = RFA_1_voiced;
out.RFA2 = RFA_2_voiced;
out.N_peaks = n_maxima_voiced;

if n_th_seg == 0
    out.F1 = F1_vector;
    out.F2 = F2_vector;
end

if show_graph %(strcmpi(plot_signal,'plot'))
    if not(n_th_seg == 0)
        %% plot transfer fuction of given segment
        
        if voiced == 1
            v_segment = ' (voiced)';
        else
            v_segment = ' (unvoiced)';
        end
    
        figure(1)
        clf()
        
        subplot(211)
        zplane(roots(flip(b_filter)),roots(flip(a_filter)))
        xlabel('Real part')
        ylabel('Imaginary part')
        title('Unit circle')
        
        subplot(212)
        plot(f,H)
        hold on
        if voiced == 1
            plot([F1_min F1_min],[H(F1_min) H(F2)],'k')
            hold on
            plot([F2_min F2_min],[H(F2_min) H(F2)],'k')
            hold on
        end
        scatter(f(loc_max),H(loc_max),'r')
        hold on
        scatter(f(loc_min),H(loc_min),'k')
        hold on
        scatter(formants,H(idx_f_formant),'b','x')
        hold on
        if voiced == 1
            plot([F1_min F2],[H(F2) H(F2)],'--k')
            plot([F2_min F2],[H(F2) H(F2)],'--k')
        end
        
        title(['Frequency response of the vocal tract: '...
                num2str(n_th_seg) '. segment' v_segment])
    
        if voiced == 0
        legend('frequency response','local maxima','local minima','poles')    
        else
            legend('frequency response',...
                ['RFA1 = ' num2str(round(RFA_1_vector,2)) ' dB'],...
                ['RFA2 = ' num2str(round(RFA_2_vector,2)) ' dB'],...
            'local maxima','local minima','poles')
        end
    
        xlabel('\itf\rm [Hz]')
        ylabel('20*log│\itH\rm│ [dB]')
    
    else
        %% plot time
    
        figure(1)
        clf()
        subplot(211)
        plot((1:length(x))/fs_new,x)
        xlabel('t [s]')
        ylabel('A')
        xlim([0 length(x)/fs_new])
        grid on
        subplot(212)
        plot(energy)
        hold on
        plot(vo,'--k')
        hold on
        plot(voicing)
        legend('normalised energy','PRAAT (F0 in set range)','voicing')
        xlabel('n [frames]')
        xlim([1 n_cols])
        ylim([-0.1 1.1])
        grid on
    
    end
end
