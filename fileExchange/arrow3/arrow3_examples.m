     % 2D vectors
     arrow3([0 0],[1 3])
     arrow3([0 0],[1 2],'-.e')
     arrow3([0 0],[10 10],'--x2',1)
     arrow3(zeros(10,2),50*rand(10,2),'x',1,3)
     arrow3(zeros(10,2),[10*rand(10,1),500*rand(10,1)],'u')
     arrow3(10*rand(10,2),50*rand(10,2),'x',1,[],1)

     % 3D vectors
     arrow3([0 0 0],[1 1 1])
     arrow3(zeros(20,3),50*rand(20,3),'--x1.5',2)
     arrow3(zeros(100,3),50*rand(100,3),'x',1,3)
     arrow3(zeros(10,3),[10*rand(10,1),500*rand(10,1),50*rand(10,1)],'a')
     arrow3(10*rand(10,3),50*rand(10,3),'x',[],[],0)

     % Just for fun
     arrow3(zeros(100,3),50*rand(100,3),'x',10,3,[],0.95)
     light('Position',[-10 -10 -10],'Style','local')
     light('Position',[60,60,60]), lighting gouraud

     % ColorOrder variable, color code prefixes, and Beta
     global ColorOrder, ColorOrder='^ui^e_hq^v';
     theta=[0:pi/22:pi/2]';
     arrow3(zeros(12,2),[cos(theta),sin(theta)],'1.5o',0.1,[],[],[],0.5)

     % ColorOrder property, LineStyleOrder, and LineWidthOrder
     global ColorOrder, ColorOrder=[];
     set(gca,'ColorOrder',[1,0,0;0,0,1;0.25,0.75,0.25;0,0,0])
     set(gca,'LineStyleOrder',{'-','--','-.',':'})
     global LineWidthOrder, LineWidthOrder=[1,2,4,8];
     w=[5,10,15,20]; h=[20,40,30,40];
     arrow3(zeros(4,2),[10*rand(4,1),500*rand(4,1)],'o*/',w,h,10)

     % Magnitude coloring
     colormap spring
     arrow3(20*randn(20,3),50*randn(20,3),'|',[],[],0)
     set(gca,'color',0.7*[1,1,1])
     set(gcf,'color',0.5*[1,1,1]), grid on, colorbar
     pause % change the colormap and update colors
     colormap hot
     arrow3('update','colors')

     % LogLog plot
     set(gca,'xscale','log','yscale','log');
     axis([1e2,1e8,1e-2,1e-1]); hold on
     p1=repmat([1e3,2e-2],15,1);
     q1=[1e7,1e6,1e5,1e4,1e3,1e7,1e7,1e7,1e7,1e7,1e7,1e6,1e5,1e4,1e3];
     q2=1e-2*[9,9,9,9,9,7,5,4,3,2,1,1,1,1,1]; p2=[q1',q2'];
     global ColorOrder, ColorOrder=[];
     set(gca,'ColorOrder',rand(15,3))
     arrow3(p1,p2,'o'), grid on, hold off

     % SemiLogX plot
     set(gca,'xscale','log','yscale','linear');
     axis([1e2,1e8,1e-2,1e-1]); hold on
     p1=repmat([1e3,0.05],15,1);
     q1=[1e7,1e6,1e5,1e4,1e3,1e7,1e7,1e7,1e7,1e7,1e7,1e6,1e5,1e4,1e3];
     q2=1e-2*[9,9,9,9,9,7,5,4,3,2,1,1,1,1,1]; p2=[q1',q2'];
     arrow3(p1,p2,'x'), grid on, hold off

     % SemiLogY plot
     set(gca,'xscale','linear','yscale','log');
     axis([2,8,1e-2,1e-1]); hold on
     p1=repmat([3,2e-2],17,1);
     q1=[7,6,5,4,3,7,7,7,7,7,7,7,7,6,5,4,3];
     q2=1e-2*[9,9,9,9,9,8,7,6,5,4,3,2,1,1,1,1,1]; p2=[q1',q2'];
     set(gca,'LineStyleOrder',{'-','--','-.',':'})
     arrow3(p1,p2,'*',1,[],0), grid on, hold off

     % Color tables
     arrow3('colors')           % default color table
     arrow3('colors',0.3)       % low contrast color table
     arrow3('colors',0.5)       % high contrast color table

     % Update initial point markers and arrowheads
     arrow3('update')           % redraw same size
     arrow3('update',2)         % redraw double size
     arrow3('update',0.5)       % redraw half size
     arrow3('update',[0.5,2,1]) % redraw W half size,
                                %        H double size, and
                                %        IP same size
