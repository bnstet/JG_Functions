



% find artifacts
stimidx = find(mean(F,1)>400);
allstimframes = unique([stimidx frameidx frameidx-1]);
F_nostim = F;
F_nostim(:,allstimframes)=[];

figure
plot(mean(F_nostim,1))

% mean subtract
F_centered = F_nostim-mean(F_nostim,2);

% normalize
for i = 1:size(F_centered,1)
F_mag(i) = norm(F_centered(i,:));
F_centered_norm(i,:) = F_centered(i,:)./F_mag(i);
end
% F_centered_norm = F_centered./norm(F_centered);

figure
imagesc(F_centered_norm)

% take the DP to get contribution
weighting = F_centered_norm*F_centered_norm(end,:)';
weighting = weighting.*(weighting>0);

weight_mat = weighting*F_centered_norm(end,:);
F_detrend = F_centered_norm-weight_mat;

[dF,F0] = compute_dff(F_detrend);

for i = 1:size(dF,1)
dF_smooth(i,:) = smooth(dF(i,:));
end

figure
imagesc(dF_smooth)

% Plot your traces
figure
for i = 1:100
    plot(dF_smooth(i,:)-(i*5))
    hold on
end
axis tight

figure
for i = 101:200
    plot(dF_smooth(i,:)-(i*5))
    hold on
end
axis tight

figure
for i = 201:300
    plot(dF_smooth(i,:)-(i*5))
    hold on
end
axis tight

F_bs = F-min(F);




[dF,F0] = compute_dff(F,prctl)