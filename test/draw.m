figure(1);
p.x = zeros(1,N);
p.y = zeros(1,N);
for i = 1:N
    p.x(i) = fishes{i}.position(1);
    p.y(i) = fishes{i}.position(2);
end
plot(p.x,p.y,'.','markersize',10);
xlim([0 T]); ylim([0 T]);
drawnow