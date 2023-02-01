format compact
format short g
clf;clear
load Data/DataMatrix4
maxn=1000; % Sets the maximum number of data points
maxx=max(DataMatrix4(maxn,1));
miny=-.1;maxy=1.4; % <<< Change to suit your data
axis([0 maxx miny maxy]);
hold on
SmoothWidth=21; % <<< Smooth width (odd integer)
AmpThreshold=.1; % <<< Detect peaks only higher than this height

% SmoothWidth=makeodd(SmoothWidth); % Optional to insure oddness.
% <<< Uncomment one of the following line to define desired smooth shape.
% SmoothVector=ones(1,SmoothWidth);SmoothVector=SmoothVector./(sum(SmoothVector));
% SmoothVector=triangle(1:SmoothWidth,SmoothWidth/2,SmoothWidth/2);SmoothVector=SmoothVector./(sum(SmoothVector));
SmoothVector=gaussian(1:SmoothWidth,SmoothWidth/2,SmoothWidth/2);SmoothVector=SmoothVector./(sum(SmoothVector));
x=zeros(1,maxn); % x is vector of simulated data points x=DataMatrix2(:,1);
y=zeros(1,maxn); % y is vector of simulated data points y=DataMatrix2(:,2);
sy=zeros(1,maxn); % sy is vector of smoothed data points
tic
PeakNumber=0;
TroughNumber=0;

for n=1:maxn
    x(n)=DataMatrix4(n,1);
    y(n)=DataMatrix4(n,2); % simulate a single data point from the data source
    FirstPoint=n-SmoothWidth;
    if FirstPoint<1;FirstPoint=1;end
    LastPoint=n-1;
    if LastPoint<1;LastPoint=1;end
    if n>SmoothWidth
        SmoothedPoint=sum(SmoothVector.*(y(FirstPoint:LastPoint)));
        sy(n)=SmoothedPoint;
    end
    if n==1
        plot(1,sy(1)) % Plot the first simulated data point
        xlabel(['X      SmoothWidth= ' num2str(SmoothWidth) '     AmpThreshold= ' num2str(AmpThreshold)]);ylabel('Y') % Label axes
        title('Real Time Smoothed Peak Detection Demo.  Black=original   Red=Smoothed')
    else
        LineStart=n-1;
        if LineStart<1;LineStart=1;end
        LineEnd=n;
        plot([x(n-1) x(n)],[sy(LineStart) sy(LineEnd)],'r') % Draw smoothed signal as red line
        plot([x(n-1) x(n)],[y(LineStart) y(LineEnd)],'k') % Draw raw signal as black line    
        if n>2 % Start peak detection when 3 points have been acquired.
            if sy(n-1)>AmpThreshold % If a point is greater than the amplitude threshold set in line 23
                if sy(n-1)>sy(n-2) % AND if a point is greater than the the previous one
                    if sy(n-1)>sy(n) % AND greater than the following one, register a peak.
                        [Height,Position,Width]=gaussfit(x(n-SmoothWidth:n),y(n-SmoothWidth:n));
                        PeakNumber=PeakNumber+1;
                        text(Position,Height,[' peak ' num2str(PeakNumber)]) % Label the peak on the graph
                        disp(['Peak ' num2str(PeakNumber) ' detected at x=' num2str(Position) ', y=' num2str(Height)  ', width= ' num2str(Width) ])
                        PeakTable(PeakNumber,:)=[PeakNumber,Position,Height,Width];
                    end
                end
            end
            if sy(n-1)< -AmpThreshold % If a point is LESS than the amplitude threshold set in line 23
                if sy(n-1)<sy(n-2) % AND if a point is LESS than the the previous one
                    if sy(n-1)<sy(n) % AND LESS than the following one, register a trough.
                        [Height,Position,Width]=gaussfit(x(n-SmoothWidth:n),y(n-SmoothWidth:n));
                        TroughNumber=TroughNumber+1;
                        text(Position,Height,[' trough ' num2str(PeakNumber)]) % Label the trough on the graph
                        disp(['Trough ' num2str(TroughNumber) ' detected at x=' num2str(Position) ', y=' num2str(Height)  ', width= ' num2str(Width) ])
                        TroughTable(TroughNumber,:)=[TroughNumber,Position,Height,Width];
                    end
                end
            end
        end
    end
    %drawnow
end

hold off
elapsedtime=toc
TimePerPoint=elapsedtime/maxn
