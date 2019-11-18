% Test of Halcyon pitch estimator using synthetic signal

Fs = 44100;     % Sampling frequency
N_Harm = 20;    % Number of harmonics
Ln = Fs*1.2;

fx_rate = linspace(0,5.0,Ln);
fx_src =175 +125*sin(cumsum(2*pi*fx_rate/Fs));

Phs=cumsum(fx_src')/Fs*2*pi;
Amps=(N_Harm:-1:1).^2;
Amps=Amps/(sum(Amps)+4);
Amps(1:2) = Amps(2:-1:1);

Sig=zeros(Ln,1);
for N=1:N_Harm
    Sig=Sig+Amps(N)*cos(Phs*N);
end

[pitch_val, time_grid] = halcyon(Sig, Fs);

%%
figure;
subplot(211);
plot(time_grid/(Fs)*1000, pitch_val,'-o',...
     (1:length(fx_src))/(Fs)*1000,fx_src);
xlim([0 max(time_grid/(Fs)*1000)]);
ylim([min(pitch_val)-25 max(pitch_val)+25]);
xlabel('Time, ms');
ylabel('Frequency');

grid on;
legend('Halcyon est','Actual f_0');
subplot(212);
plot((1:length(fx_src))/(Fs)*1000,Sig);

ylim([-0.3 1.1]);
xlim([0 max(time_grid/(Fs)*1000)]);
xlabel('Time, ms'); 
grid on;