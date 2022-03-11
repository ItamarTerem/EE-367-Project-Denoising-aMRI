function opts = addNoise(opts)

s = opts.rice_s; % parameter s for Rician noise

frames = ricernd(opts.frames, s);
opts.frames = frames;

[opts.rice_mean,opts.rice_sd] = ricestat(0,s);


end %function
