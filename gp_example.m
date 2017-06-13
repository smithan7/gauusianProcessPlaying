% gaussian process example
% https://www.robots.ox.ac.uk/~mebden/reports/GPtutorial.pdf

% control example 
% http://mlg.eng.cam.ac.uk/pub/pdf/KocMurRasLik03.pdf

% multiple gps for estimating a persons pose
% http://www.maths.lth.se/matematiklth/personal/sminchis/code/TGP.html

% multi input gp for control
% http://www.dcs.gla.ac.uk/~rod/publications/KocGirBanMur03.pdf

% gp for uav sys id
% file:///home/andy/Downloads/Hemakumara2013_ICRA_GaussianProcess.pdf

% I think to go to multiple observations, X(i) is a vector not number, for covariance you bustract the complete whole vector
% to get the distance between each entry and then sum the distances. so for X(i) = [1xn] -> xs = sum_j=1^n (X(i,j) - X'(l,j))^2

% next goal is to include a model of a car and predict it's model as it drives around, from x,y,theta,xdot,ydot,thetadot predict x',y',theta',xdot',ydot',thetadot'
% really this means predicting just the dots and then solving for the velocity. I think a key will be to use greedy selection of points so that 
% the matrix inverse is manageable

% maybe as part of the vector include my state information? for puruit evasion.


close all
clear all
clc

%x = [-1.5, -1.0, -0.75, -0.4, -0.25, 0.00, 7, 4, 1, 2, 2.01,6.985];
%y = [-1.6, -1.1, -0.4, 0.1, 0.5, 0.75, 1, -1, -1.5, 0, 2,-3];

x = 0.1:0.1:10;
y = sin(x) + randn(1,length(x))/5;

s = ones(length(x),1)*0.2;

l = 1; % length parameter - how much distance between x's matters, large l means the distance matters less
sigma_f = 1.27; % maximum allowable covariance - large with functions with large range of y values
sigma_f_sq = sigma_f^2;
sigma_n = 0.2; % actual uncertainty in the data
sigma_n_sq = sigma_n^2;

% GP 1 is normal homeoscedastic GP
yp = zeros(1, length(y));
z = zeros(1, length(y));
for i=1:length(x)
    [yp(i), yv] = gp_predict(x(i) + randn()/100, x, y, sigma_f_sq, sigma_n_sq, l);
    
    z(i) = log(0.5*(y(i)-yp(i))^2);
end

% GP 2 on noise from GP 1
r = zeros(1, length(y));
for i=1:length(x)
    [r(i), nv] = gp_predict(x(i) + randn()/100, x, z, sigma_f_sq, sigma_n_sq, l);
end

% GP 3 = GP 1 + R found from GP 2
ypp = zeros(1, length(y));
for i=1:length(x)
    [ypp(i), nv] = gp_predict(x(i) + randn()/100, x, z, sigma_f_sq, sigma_n_sq, l, r);
end

% this is strictly just to plot over the range the mean value of the GP
figure
hold all
% plot function over range
x_min = min(x);
x_max = max(x);
xs = x_min - 1;
while xs < x_max + 1
    xs = xs + 0.1;
    
    [ys, yv] = gp_predict(xs, x, y, sigma_f_sq, sigma_n_sq, l);

    errorbar(xs,ys,yv, 'g.')
end
% plot actual data
errorbar(x,y,s, 'r.')
plot(x,y,'k.')
xlabel('x')
ylabel('y')
% finish pretty plot

figure
subplot(2,1,1)
plot(x,y,'bo',x,yp,'rx')
legend('Truth','GP1')
ylabel('y')
subplot(2,1,2)
plot(x,z,'bx')
ylabel('var')
xlabel('x')

figure
plot(x,r,'rx')
xlabel('x')
ylabel('r(x)~GP2(var(x))')

figure
plot(x,ypp,'rx',x,y,'bo')
legend('GP3','Truth')
xlabel('x')
ylabel('y')


