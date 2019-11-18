function [fine_pitch_values, time_grid]=halcyon(s,fs)

if exist('halcyon_cfg.mat','file')==2
    load('halcyon_cfg');
else
    fprintf('Generating cfg-file ...');
    cfg = build_halcyon_cfg();
    fprintf(' Done.\n');
end

s=resample(s, cfg.fs_input,fs);

frame_offset=32;

samples=1:frame_offset:length(s)-cfg.ln_frame+1;

N_frames=length(samples);

nccf_surf=zeros(cfg.n_grid_lines,N_frames);
win_equalize=linspace(0.8,1,cfg.n_grid_lines);

fine_pitch_surf=zeros(cfg.n_grid_lines,N_frames);

eps=10^-12;

dp_max_step=5;

wind=fir1(cfg.ft_size-1,1/cfg.ft_size*2,'noscale');
wind_mtx=repmat(wind',1,cfg.n_grid_lines);
harm_mtx=repmat((1:cfg.n_harms)',1,cfg.n_grid_lines);

for F=1:N_frames

    frame=s((F-1)*frame_offset+1:(F-1)*frame_offset+cfg.ln_frame);

    frc_norm_mtx=repmat(cfg.sampling_freqs,cfg.n_harms,1);

    frc_grid_mtx=repmat(cfg.candidate_grid,cfg.n_harms,1);

    inds_harms=[2 4 6 8 10 12 14 16]*2+1; % FFT bins of interest

    n_picks=cfg.block_size-cfg.ft_size+1; % Always even

    params=zeros(n_picks,cfg.n_harms,cfg.n_grid_lines);

    block=cfg.resample_matrix*frame;
    block=reshape(block,cfg.block_size,cfg.n_grid_lines);

    for N=1:n_picks
        
        w_block=block(N:N+cfg.ft_size-1,:).*wind_mtx;

        k=sqrt(sum(w_block.^2,1)); %Normalization - frames of different lengths should be of same energy
        
        k=max(k,eps);
        
        w_block=w_block./repmat(k,cfg.ft_size,1);
        
        fft_frames=fft(w_block,[],1);
        
        params(N,:,:)=fft_frames(inds_harms,:);
    end

    phs=angle(params);
    
    nccf_alcyon_block=zeros(n_picks-1,cfg.n_grid_lines);
    
    for N=1:n_picks-1
        phs(N+1,:,:)=phs(N+1,:,:)-round((phs(N+1,:,:)-phs(N,:,:))/2/pi)*2*pi; % Unwraping phases
        frc=phs(N+1,:,:)-phs(N,:,:);
        frc=reshape(frc,cfg.n_harms,cfg.n_grid_lines);
        
        amp_cur=abs(params(N,:,:));
        amp_cur=reshape(amp_cur,cfg.n_harms,cfg.n_grid_lines);
        
        nccf_alcyon_block(N,:)=sum((amp_cur*1+0).^1.*cos(frc.*frc_norm_mtx./frc_grid_mtx));
        
    end
    
    nccf_alcyon_block=nccf_alcyon_block.*repmat(win_equalize,n_picks-1,1);
      
    nccf_alcyon0=prod(nccf_alcyon_block,1);
    
    nccf_surf(:,F)=nccf_alcyon0/max(nccf_alcyon0);
    
    amp_cur=max(amp_cur,eps);
    
    fine_pitch_vec=sum(frc.*frc_norm_mtx./harm_mtx.*amp_cur,1)./sum(amp_cur,1)/2/pi;
    
    fine_pitch_surf(:,F)=fine_pitch_vec;
end

[~,q]=dp(-nccf_surf',dp_max_step);

fine_pitch_values=zeros(1,N_frames);
for N=1:N_frames
    fine_pitch_values(N)=fine_pitch_surf(q(N),N);
end

time_grid = (samples + (cfg.ln_frame-1)/2-1)*fs/cfg.fs_input;
end