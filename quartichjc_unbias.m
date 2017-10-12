function [Cm]=quartichjc_bias(TrP, max_iter)
% ------------------------------------------------------------------------------------------
% Description: Calculation of the hip joint center HJC.
% [Cm]=metodo1bUb(TrP).
% ------------------------------------------------------------------------------------------
% INPUT: TrP clean matrix containing markers'trajectories in the proximal system of reference.
%            dim(TrP)=Nc*3p where Nc is number of good samples and p is the number of distal markers
% OUTPUT: Cm vector with the coordinates of hip joint center (Cx,Cy,Cz).
%------------------------------------------------------------------------------------------
% Comments: metodo1bUb extracts HJC position as the centre of the optimal spherical suface that minimizes the root mean square error 
%           between the radius(unknown) and the distance of the centroid of marker's coordinates from sphere center(unknown).
%           Using definition of vector differentiation the problem can be expressed as: A*Cm=B, that is a
%           linear equation system. This version is optimized by Halvorsen.
% References: Gamage, Lasenby J. (2002).New least squares solutions for estimating the average centre of rotation and the axis of rotation.
%             Journal of Biomechanics 35, 87-93 2002. 
%             In this method is implementede the bias correction proposed by Halvorsen (Halvorsen, Journal of Biomechanics 36 (2003) 999–1008).
% Author Andrea Cereatti.
% Date
% Modified 4/3/08 to different function name, added function "distance",
% maximum iterations
% Ajit Chaudhari
%------------------------------------------------------------------------------------------
[r c]=size(TrP);
D=zeros(3);
V1=[];
V2=[];
V3=[];
b1=[0 0 0];
for j=1:3:c
    d1=zeros(3);
    V2a=0;
    V3a=[0 0 0];
    for i=1:r 
        d1=[d1+TrP(i,j:j+2)'*(TrP(i,j:j+2))];       %  dim(b)=3*3
        a=(TrP(i,j).^2+TrP(i,j+1).^2+TrP(i,j+2).^2);
        V2a=V2a+a;     % dim(V2a)=1
        V3a=V3a+a*TrP(i,j:j+2);     %dim(V3a)=1*3
    end
    D=D+(d1/r);     %  dim(D)=3*3
    V2=[V2,V2a/r];  % dim(V2a)=1*p    
    b1=[b1+V3a/r];      % dim(b1)=1*3
end
V1=mean(TrP);      % dim(V1)=1*(3P)
 p=size(V1,2);
 e1=0;
 E=zeros(3);
 f1=[0 0 0];
 F=[0 0 0];
 for k=1:3:p
     e1=V1(k:k+2)'*V1(k:k+2);       %dim(e1)=3*3
     E=E+e1;     % dim(E)=3*3
     f1=V2((k-1)/3+1)*V1(k:k+2);       %dim(f)=1*3
     F=F+f1;      %dim(F)=1*3
 end
% equation (5) of Gamage and Lasenby
A=2*(D-E);      %dim(A)=3*3
B=(b1-F)';         %dim(B)=3*1
[U,S,V] = svd(A);
Cm_in=V*inv(S)*U'*B;
Cm_old=Cm_in+[1,1,1]';
kk=0;
iterations = 0;
while (distance(Cm_old',Cm_in')>0.0000001 && iterations<max_iter)
    kk=kk+1;
    Cm_old=Cm_in;
    sigma2=[];
    for j=1:3:c
        marker=TrP(:,j:j+2);
        Ukp=marker-(Cm_in*ones(1,r))';
        % computation of u^2
        u2=0;
        app=[];
        for i=1:r
            u2=u2+Ukp(i,:)*Ukp(i,:)';
            app=[app,Ukp(i,:)*Ukp(i,:)'];
        end
        u2=u2/r;
        % computation of sigma
        sigmaP=0;
        for i=1:r
            sigmaP=sigmaP+(app(i)-u2)^2;
        end
        sigmaP=sigmaP/(4*u2*r);
        sigma2=[sigma2;sigmaP];
    end
    sigma2=mean(sigma2);
    % computation of deltaB
    deltaB = 0;
    for j=1:3:c
        deltaB=deltaB + V1(j:j+2)'-Cm_in;
    end
    deltaB=2*sigma2*deltaB;
    Bcorr=B-deltaB; % corrected term B
    % iterative estimation  of the centre of rotation
    [U,S,V] = svd(A);
    Cm_in=V*inv(S)*U'*Bcorr;
    iterations = iterations + 1;
    if (mod(iterations,100)==0),
        fprintf(1,'.');
    end
    if (mod(iterations,1000)==0),
        fprintf(1,'%d\n',distance(Cm_old',Cm_in'));
    end
end
Cm=Cm_in;

function [d] = distance(V1,V2),
diff = V1-V2;
d = norm(diff);