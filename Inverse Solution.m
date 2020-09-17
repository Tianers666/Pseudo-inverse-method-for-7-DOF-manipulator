%/*�ݶ�ͶӰ����7-DOF��е�����
% *�汾��2019b
% *2020.09.17
% *Written by Rot_Tianers*/

clear;clc;set(0,'defaultfigurecolor','w');
%%�趨ֱ�߳�ʼ���ĩ�˵㣨�������Ϳ������޸�,ע��ʼĩ���ѡȡҪ�ڹ����ռ�֮�ڣ�
Initial = [-0.8025,0,0.2767];
End = [-0.6551,0.2,0.6037];
%%���ò���
deta = 0.01;
%%��ֱ�߳���
lline = sqrt(((Initial(1)-End(1))^2+(Initial(2)-End(2))^2+(Initial(3)-End(3))^2));
%%��������
if rem(lline,deta) == 0
    STEP = lline/deta;
else
    STEP = floor(lline/deta)+1;
end
posx(1) = Initial(1);
posy(1) = Initial(2);
posz(1) = Initial(3);
for i=1:STEP
    posx(i+1) = Initial(1)+(End(1)-Initial(1))/STEP*i;
    posy(i+1) = Initial(2)+(End(2)-Initial(2))/STEP*i;
    posz(i+1) = Initial(3)+(End(3)-Initial(3))/STEP*i;
end
%%=========Ԥ�ڹ켣===================================================%%

%%iiwa��е��DH����
BS = 0.34;SE = 0.4;EW = 0.4;WT = 0.1266;
L(1) = Link('d', BS, 'a', 0, 'alpha', 0,'modified');
L(2) = Link('d', 0, 'a', 0, 'alpha', pi/2,'modified');
L(3) = Link('d', SE, 'a', 0, 'alpha', -pi/2,'modified');
L(4) = Link('d', 0, 'a', 0, 'alpha', pi/2,'modified');
L(5) = Link('d', EW, 'a', 0, 'alpha', -pi/2,'modified');
L(6) = Link('d', 0, 'a', 0, 'alpha', pi/2,'modified');
L(7) = Link('d', WT, 'a', 0, 'alpha', -pi/2,'modified');
bot = SerialLink([L(1) L(2) L(3) L(4) L(5) L(6) L(7)],'name','KUKA iiwa7');
%%��ʼ�ؽڽ�
Initial_q = [0 pi/3 0 pi/3 0 0 0];
dx = [0;0;0;0;0;0];

%% ���ùؽڼ��޷�Χ
qmax = deg2rad([170 120 170 120 170 120 175]);
qmin = deg2rad([-170 -120 -170 -120 -170 -120 -175]);

%%��̬�仯
Ori_ini = [0,0,0];
%%��ֹ��λ��
Ori_end = [0,pi/3,0];

%%��ֵ׼������
q = Initial_q;
Theta(1,:) = rad2deg(q);
for i=1:STEP
    %%λ��΢�ֲ�
    dx(1) = posx(i+1)-posx(i);
    dx(2) = posy(i+1)-posy(i);
    dx(3) = posz(i+1)-posz(i);
    %%��̬΢�ֲ�����̬�����仯���ɣ�
    dx(4) = (Ori_end(1)-Ori_ini(1))/STEP;
    dx(5) = (Ori_end(2)-Ori_ini(2))/STEP;
    dx(6) = (Ori_end(3)-Ori_ini(3))/STEP;
    %%���ſɱȾ���
    J = bot.jacob0(q);
    sigma = 0.02;  %%��С����ֵ�߽�,ȡֵ��ΧҪ�����ӽ�0
    lambda0 = 5;   %%����ϵ��
    %%������С���˷��������
    sv = svd(J);
    sor = sort(sv); %%���ſɱȾ��������ֵ
    theta = sor(1); %%�õ���С����ֵ
    %%������ϵ����������С���˷�
    if theta < sigma
        lambda=lambda0^2*(1-(theta/sigma)^2);
    else
        lambda=0;
    end
    MPJ = J'/(J*J'+lambda*eye(6,6));   %%MPJ�ǲ���������С���˷��ó���α�棨Ҳ��Ϊ����³�����棩����lanmda2=0ʱ���˻�Ϊ��ͨ��α�淨
    %%�ܼ���ָ��
    I = eye(7,7);
    K = -10;  %%�Ŵ�ϵ����Ŀ�꺯��ȡ��СʱΪ����ȡ���ʱΪ��
    for j = 1:7
       a(j) = (qmax(j)+qmin(j))/2;  %%��i���ؽ���ֵ
       dH(j) = 2*(q(j)-a(j))/(7*(a(j)-qmax(j))^2);  %%�ܹؽڼ����Ż��������ݶ�
    end
    %%�ݶ�ͶӰ������ռ��Ż�ָ��
    NJ = K*(I-MPJ*J)*dH';  %%dH��7��1������
    dq = MPJ*dx+NJ;
    q = q+dq';
    %%��¼ÿһ�ιؽڽ�
    Theta(i+1,:) = rad2deg(q);
end

%%���߸��ؽ�����
plot(1:STEP+1,Theta(:,1)','-d','Markersize',8,'linewidth',1.5);
hold on;
plot(1:STEP+1,Theta(:,2)','-o','Markersize',8,'linewidth',1.5);
hold on;
plot(1:STEP+1,Theta(:,3)','-*','Markersize',8,'linewidth',1.5);
hold on;
plot(1:STEP+1,Theta(:,4)','--h','Markersize',8,'linewidth',1.5);
hold on;
plot(1:STEP+1,Theta(:,5)',':x','Markersize',8,'linewidth',1.5);
hold on;
plot(1:STEP+1,Theta(:,6)',':s','Markersize',8,'linewidth',1.5);
hold on;
plot(1:STEP+1,Theta(:,7)',':p','Markersize',8,'linewidth',1.5);
hold on;
legend('\theta1','\theta2','\theta3','\theta4','\theta5','\theta6','\theta7','orientation','horizontal');

%%��֤ĩ������ֵ
bot.fkine(q);

%%���ӻ�ʼĩ����״̬�Ļ�е��
figure;
robot = importrobot('iiwa7.urdf');
robot.DataFormat='column';
%%��ʼ�ؽڽ�
q0 = [Initial_q(1);Initial_q(2);Initial_q(3);Initial_q(4);Initial_q(5);Initial_q(6);Initial_q(7)];
show(robot,q0,'PreservePlot',true);
hold on;
%%ĩ�˹ؽڽ�
qn = [q(1);q(2);q(3);q(4);q(5);q(6);q(7)];
show(robot,qn,'PreservePlot',true);
%%ͼƬ��ʾ��һЩ����
axis([-0.6 0.6 -0.6 0.6 0 1.35]);%%���귶Χ
box on;
camva('auto');  %%��������ӽ�
daspect([1 1 1]); %%������ÿ��������ݵ�λ����,Ҫ�����з����ϲ�����ͬ�����ݵ�λ���ȣ�ʹ�� [1 1 1] 
set(gca,'FontSize',20,'Fontname', 'Times New Roman','linewidth',1.2);
xlabel('x(m)','FontSize',20);
ylabel('y(m)','FontSize',20);
zlabel('z(m)','FontSize',20);
set(gca,'XColor','k','YColor','k');
%%�������