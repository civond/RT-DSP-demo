function [Height, Position, Width]=gaussfit(x,y)
maxy=max(y);
for p=1:length(y),
    if y(p)<(maxy/1000),y(p)=maxy/1000;end
end % for p=1:length(y),
    logyyy=log(abs(y));
    [coef,S,MU]=polyfit(x,logyyy,2);
    c1=coef(3);c2=coef(2);c3=coef(1);
    % Compute peak position and height or fitted parabola
    Position=-((MU(2).*c2/(2*c3))-MU(1));
    Height=exp(c1-c3*(c2/(2*c3))^2);
    Width=norm(MU(2).*2.35482/(sqrt(2)*sqrt(-1*c3)));
