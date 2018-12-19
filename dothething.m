function dothething(input)
close all
figure(1)
plot(input)
figure(2)
smoothline=smooth(input,.03,'sgolay',7);
plot(smoothline)
figure(3)
plot(input-smoothline)