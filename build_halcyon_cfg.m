function cfg = build_halcyon_cfg()

fs_input=7350;

min_f0_freq=50;
max_f0_freq=450;

n_grid_lines=100;

n_harms=8;

candidate_grid=2.^linspace(log2(min_f0_freq),log2(max_f0_freq),n_grid_lines);

sampling_freqs=candidate_grid*(n_harms*2+1);
cutoff_freqs=sampling_freqs/2;

ft_size=(n_harms*2*2+2)*2;  % even !!

block_h_size=ft_size/2+1; % add a value here to extend median-minimum filtering interval
block_size=block_h_size*2+1;  % odd!

interp_h_size=15*2*2;

max_offset=round(block_h_size*fs_input/sampling_freqs(1))+interp_h_size;

resample_matrix=zeros(n_grid_lines*block_size,max_offset*2+1);

for L=1:n_grid_lines % grid lines
    for B=-block_h_size:block_h_size % block samples
        
        cutoff=cutoff_freqs(L);
        offset=B*fs_input/sampling_freqs(L);
        
        int_offset=round(offset);
        fract_offset=int_offset-offset;
        
        sinc_step=cutoff/(fs_input/2);
        
        imp=sinc(fract_offset*sinc_step-sinc_step*interp_h_size:sinc_step:fract_offset*sinc_step+sinc_step*interp_h_size);
        imp=imp.*(0.54+0.46*cos(((-interp_h_size:interp_h_size)+fract_offset)*2*pi/(interp_h_size*2+1)));

        imp=imp/sum(imp);
        
        resample_matrix((L-1)*block_size+B+block_h_size+1,(int_offset-interp_h_size:int_offset+interp_h_size)+max_offset+1)=imp;
        
    end
end

clear cfg;
cfg.n_harms=n_harms;
cfg.ft_size=ft_size;
cfg.block_size=block_size;
cfg.fs_input=fs_input;

cfg.n_grid_lines=n_grid_lines;
cfg.candidate_grid=candidate_grid;
cfg.sampling_freqs=sampling_freqs;
cfg.cutoff_freqs=cutoff_freqs;
cfg.resample_matrix=resample_matrix;
cfg.ln_frame=size(cfg.resample_matrix,2);

save('halcyon_cfg','cfg');

end
