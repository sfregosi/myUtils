


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                             Configuration                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% The third column of tasks{} is '-' for a solid line, '--' for a dashed one,
% ':' for a dotted one. It defaults to '-'.

% textleft controls spacing between the text and the grid.  The value here may
% be overridden below. Sometimes the MATLAB figure text and the saved .png
% figure text have different widths, so check the .png image before using it.
textleft = 10;

% This controls whether tasks are numbered or lettered.
textTasks = true;		% lettered; can also be true, 'none')

% This specifies what labels go up top.  It is usually overridden below.
yearlabels = 2010:2013;

% This specifies how many units to divide the year into. Normally it's quarters,
% but this is sometimes overridden below. Setting div=12 gets months.
div = 4;

% This specifies text size. Occasionally one wants it smaller.
fontsize = 10;

months = {'Jan' 'Feb' 'Mar' 'Apr' 'May' 'Jun' 'Jul' 'Aug' 'Sep' 'Oct' 'Nov' 'Dec'};

if (1)
  tasks = {
      'Technical reviews'		'Jun 21-Sep 23' ':'
      'Transition Plan'                 'Jun 21-Nov 21' ':'
      'Glider prep. (1)'                'Jul 21-Feb 22' ':'
      'Glider operation (1)'		'Mar 22-Jun 22' '-'
      'Data management (1)'		'Jun 22-Sep 22' ':'
      'Data analysis (1)'		'Sep 22-Mar 23' ':'
      'Real-time system'                'Jul 21-Sep 22' ':'
      'Glider prep. (2)'		'Jun 22-Aug 22' '-'
      'Glider operation (2)'		'Sep 22-Nov 22' '-'
      'Data management (2)'		'Nov 22-Jan 23' '-'
      'Data analysis (2)'		'Dec 22-Aug 23' '-'
      'Assess effectiveness'            'Jan 23-Sep 23' '-'
      'Publication & reporting'         'Dec 21-Sep 23' ':'
      };
  yearlabels = 2021:2023;
  div = 4;
  outdir = 'C:\Dave\00writing\00proposals\HI_gliders';
  textleft = 10;		% spacing between text and grid
  textTasks = false;		% numbered
  fontsize = 9;
elseif (0)
  tasks = {
      'Flight simulation'		'Jan 21-Sep 23' ':'
      '3-D localization'		'Jul 21-Dec 22' ':'
      'Statistical methods'		'Jul 21-Dec 23' ':'
      'Glider prep & flight'		'Jan 21-Nov 21' '-'
      'Detection'			'Nov 21-Sep 22' '-'
      'Location application'		'Jan 22-Dec 22' '-'
      'Detection function application'	'Jul 22-Jul 23' '-'
      'Density analysis'		'Apr 22-Dec 23' '-'
      };
  yearlabels = 2021:2023;
  div = 4;
  outdir = 'C:\Dave\00writing\DECAF-LenThomas\MultiGliderDensity-2020';
  textleft = 20;		% spacing between text and grid
  textTasks = false;		% numbered
elseif (0)
  tasks = {
      'Glider preparation'		'Jun 20-Aug 20' '-'
      'Time sync software'		'Jun 20-Jul 20' '-'
      'Detection software'		'Jun 20-Jul 20' '-'
      'Localization software'	'Jul 20-Aug 20' '-'
      'Test mission'			'Sep 20-Sep 20' '-'
      'Data analysis'			'Sep 20-Sep 20' '-'
      'Project management'		'Jun 20-Sep 20' ':'
      };
  yearlabels = 2020;
  div = 12;
  outdir = 'C:\Dave\00writing\00proposals\OMAO-UxS';
  textleft = 2.2;		% spacing between text and grid
  textTasks = false;		% numbered
elseif (0)
  tasks = {
      'Student training'		'Jan 15-Dec 17' '-'
      'Glider preparation 2015'		'Jan 15-Jun 15' '--'
      'Glider operation 2015'		'Jul 15-Jul 15' '-'
      'Data analysis, 2015 data'	'Jul 15-Dec 16' '--'
      'Glider preparation 2017'		'Jan 17-Jun 17' '--'
      'Glider operation 2017'		'Jul 17-Jul 17' '-'
      'Data analysis, 2017 data'	'Jul 17-Dec 17' '-'
      'Outreach: Web site'		'Jan 15-Dec 17' '--'
      'Outreach: Public presentations'	'Jan 15-Dec 17' '--'
      'Science publication/presentation' 'Sep 15-Dec 17' '--'
      };
  yearlabels = 2015:2017;
  outdir = 'C:\Dave\00writing\00proposals\GoMRI-Sidorovskaia14\';
  textleft = 15;		% spacing between text and grid
  textTasks = true;		% lettered
elseif (0)
  tasks = {
      'Whale call detectors'		'Apr 15-Dec 15' '-'
      'Check detections'		'May 15-Jun 16' '--'
      'Calculate density'		'Oct 15-Sep 16' '-'
      'Collect ocean data'		'Sep 15-Dec 16' '--'
      'Develop model'			'Jul 16-Mar 18' '-'
      'Publication, presentation'	'Dec 15-Mar 18' '--'
      };
  yearlabels = 2015:2017;
  %outdir = 'C:\Dave\00writing\proposals\ONR\SOSUS-Stafford-Sep13\';
  outdir = 'C:\Dave\00writing\00proposals\ONR\SOSUS-Stafford-Sep14\proposal-Sep14\'
  textleft = 15;		% spacing between text and grid
  textTasks = true;		% lettered
elseif (0)
  tasks = {
      'Prepare detection data'		'Apr 11-Sep 12' '-'
      'Detection: Spectrogram corr.'	'May 11-Mar 12' '-'
      'Detection: Teager-Kaiser'	'Oct 11-Sep 12' '-'
      'Detection: Classification'	'Apr 12-Mar 13' '-'
      'Prepare localization data'	'Jan 12-Jun 12' '-'
      'Localization algorithm'		'Jul 12-Mar 13' '-'
      'Publication, presentation'	'Jan 12-May 13' '-'
      };
  yearlabels = 2011:2013;
  outdir = 'D:\Dave\00writing\proposals\DoE-detection\';
  textleft = 15;		% spacing between text and grid
  textTasks = false;		% numbered
elseif (0)
  tasks = {
      'Characterization test'	'Apr 08-Jun 08'
      'Annotate recordings'	'Jun 08-Dec 08'
      'Compare recordings'	'Jul 08-Dec 08'
      'Assess algorithms'	'Jun 08-Dec 08'
      'Develop algorithm'	'Jun 08-Jun 09'
      'Port to ASG'		'Jun 08-Dec 08'
      'In-water testing'	'Jun 08-Jun 09'
      'Range test'		'Mar 09-Jul 09'
      'Fleet demonstration'	'Jun 09-Sep 09'
      'Plan future work'	'Jul 09-Dec 09'
      };
  outdir = 'C:\Dave\00writing\ONRglider-AUTEC-Oasis-UW\';
elseif (0)
  tasks = {
      'Find new beaked recordings'	'Jun 08-Aug 08'	'-'
      'Collect beaked recordings'	'Jul 08-Dec 08'	'-'
      'Annotate beaked recordings'	'Aug 08-May 09'	'-'
      'Find other odont recordings'	'Aug 08-Oct 08'	'-'
      'Collect other odont recordings'	'Sep 08-Mar 09'	'-'
      'Annotate other odont recordings'	'Oct 08-May 09'	'-'
      'Develop detection methods'	'Mar 09-Feb 10'	'-'
      'Disseminate results'		'Jun 08-Feb 10'	'-'
      };
  outdir = 'C:\Dave\00writing\FrankStone\proposal-FY08\';
elseif (0)
  tasks = {
      'Find new beaked recordings'		'Jul 09-Aug 09'	'-'
      'Collect beaked recordings'		'Jul 09-Dec 09'	'-'
      'Annotate beaked recordings'		'Aug 09-May 10'	'-'
      'Find other odontocete recordings'	'Aug 09-Oct 09'	'-'
      'Collect other odontocete recordings'	'Sep 09-Mar 10'	'-'
      'Annotate other odontocete recordings'	'Oct 09-May 10'	'-'
      'Develop detection methods'		'Jul 09-Jun 10'	'-'
      'Disseminate results'			'Jul 09-Jun 10'	'--'
      };
  outdir = 'C:\Dave\00writing\FrankStone\proposal-FY09\';
  textleft = 14;		% spacing between text and grid
  yearlabels = 2009:2010;
elseif (0)
  % original (sent in Aug. 2009)
  tasks = {
      'Hire software developer'			'Apr 10-Jun 10' '-'
      'Train developer about Ishmael'		'Jun 10-Jan 11' '-'
      'Implement improvements in list'		'Aug 10-Mar 13' '-'
      'Documentation'				'Jul 10-Mar 13' '--'
      'User technical support'			'Aug 10-Mar 13' '--'
      'Debugging'				'Sep 10-Mar 13' '--'
      'Publishing and Reporting'		'Apr 10-Mar 13' '--'
      };
  % revision (sent in Jan. 2010)
  tasks = {
      'Hire software developer'			'Jul 10-Sep 10' '-'
      'Train developer about Ishmael'		'Oct 10-Apr 11' '-'
      'Implement improvements in list'		'Dec 10-Jun 13' '-'
      'Documentation'				'Oct 10-Jun 13' '--'
      'User technical support'			'Oct 10-Jun 13' '--'
      'Debugging'				'Oct 10-Jun 13' '--'
      'Publishing and Reporting'		'Jul 10-Jun 13' '--'
      };
  yearlabels = 2010:2013;
  outdir = ...
      'C:\Dave\00writing\proposals\ONR proposals, summer09\Mellinger-Ishmael\';
  textleft = 18;		% spacing between text and grid
elseif (0)
  tasks = {
      'Develop algorithms and software'		'Apr 10-Mar 12' '-'
      'Software for OASIS sensor'		'Apr 11-Feb 12' '-'
      'Operate glider on Navy Range'		'Apr 10-Mar 11' '-'
      'Test glider with OASIS system'		'Jul 11-Mar 12' '--'
      'Long-duration beaked whale test'		'Oct 10-Sep 11' '--'
      'Publishing and Reporting'		'Apr 10-Mar 12' '--'
      };
  yearlabels = 2010:2012;
  outdir = ...
      'C:\Dave\00writing\proposals\ONR proposals, summer09\Mellinger-Ishmael\';
  textleft = 18;		% spacing between text and grid
elseif (0)
  % Frank Stone/NPS.
  tasks = {
      'Annotate recordings'			'Jul 11-Jun 12' '-'
      'Detection/classification'		'Jul 11-Dec 11' '--'
      'Density estimation'			'Aug 11-Mar 12' '--'
      'Workshop'				'Jul 11-Feb 12' '--'
      'Option 1'				'Jul 12-Jun 13' '-'
      'Option 2'				'Jul 13-Dec 13' '-'
%       'Option 3'				'Jul 11-Jun 12' '-'
%       'Option 4'				'Jul 12-Jun 13' '-'
%       'Option 5'				'Jul 13-Jun 14' '-'
      };
  yearlabels = 2011:2014;
%   outdir = ...
%       'D:\Dave\00writing\FrankStone\proposal-FY11\proposal-submittedToNpsApr11';
  outdir = ...
      'C:\Dave\00writing\FrankStone\proposal-FY13-sendApr13';
  textleft = 14;		% spacing between text and grid
elseif (0)
  % Proposal w/William Wilcock, Kate S, Anne Trehu.
  tasks = {
      '1    Fin/blue whale detections'		'Apr 13-Jun 14' '-'
      '2    Fin whale tracks'			'Jul 13-Jun 15' '-'
      '2    Blue whale tracks'			'Oct 13-Dec 15' '-'
      '3.1 Fin/blue density (range method)'	'Oct 13-Mar 16' '-'
      '3.2 Fin/blue density (energy method)'	'Apr 13-Mar 16' '-'
      '4    Interpretation'			'Jan 14-Mar 16' '-'
      '5    Project management & meetings'	'Apr 13-Mar 16' '--'
      %'Option 1: 2013-14 data'			'Apr 16-Mar 17' '-'
      %'Option 2: 2014-15 data'			'Apr 17-Mar 18' '-'
      };
  yearlabels = 2013:2016;
  outdir = ...
      'C:\Dave\00writing\proposals\ONR\Wilcock-Cascadia-Mar12';
  textleft = 18;		% spacing between text and grid
  textTasks = 'none';		% not lettered
elseif (0)
  % Proposal of Lu.
  tasks = {
      '1    Fin/blue whale detections'		'Apr 13-Jun 14' '-'
      '2    Fin whale tracks'			'Jul 13-Jun 15' '-'
      '2    Blue whale tracks'			'Oct 13-Dec 15' '-'
      '3.1 Fin/blue density (range method)'	'Oct 13-Mar 16' '-'
      '3.2 Fin/blue density (energy method)'	'Apr 13-Mar 16' '-'
      '4    Interpretation'			'Jan 14-Mar 16' '-'
      '5    Project management & meetings'	'Apr 13-Mar 16' '--'
      %'Option 1: 2013-14 data'			'Apr 16-Mar 17' '-'
      %'Option 2: 2014-15 data'			'Apr 17-Mar 18' '-'
      };
  yearlabels = 2013:2016;
  outdir = ...
      'C:\Dave\00writing\proposals\ONR\Lu-clicks+whistles-Mar12';
  textleft = 18;		% spacing between text and grid
  textTasks = 'none';		% not lettered
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       End of Configuration                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clf
dt = [];
n = nRows(tasks);

span = [inf -inf];
% Get the dates.
for i = 1 : n
  dts = tasks{i,2};
  dash = strindex(dts, '-');
  dt(i,1) = datenum(dts(1 : dash-1),   'mmm yy');
  dt(i,2) = datenum(dts(dash+1 : end), 'mmm yy');

  % Fix end-date so it's the last day of the month, not the first.
  dv1 = datevec(dt(i,1));
  dv2 = datevec(dt(i,2));
  dt(i,2) = datenum(dv2(1), dv2(2), 30);
  
  % Calculate start- and end-quarters (or months)
  if (div == 4)
    % Quarters.
    span(1) = min(span(1), datenum(dv1(1), floor((dv1(2)-1)/3)*3+1, 1));
    span(2) = max(span(2), datenum(dv2(1),  ceil((dv2(2)-1)/3)*3+1, 1));
  else
    % Months.
    span(1) = min(span(1), datenum(dv1(1), dv1(2),   1));
    span(2) = max(span(2), datenum(dv2(1), dv2(2)+1, 1));
  end
end

% Image the text and horizontal lines.
for i = 1 : n
  title = sprintf('%s', tasks{i,1});
  text(span(1) - 30.4*textleft, n-i, title, 'Horiz', 'left', 'Vert', 'middle', ...
    'FontSize', fontsize);
  if (textTasks)
    if (islogical(textTasks))
      text(span(1) - 30.4*textleft, n-i, [num2str(i) '. '], ...
	  'Horiz', 'right', 'Vert', 'middle', 'FontSize', fontsize);
    end
  else
    text(span(1) - 30.4*textleft, n-i, [num2str(i) '. '], ...
	'Horiz', 'right', 'Vert', 'middle', 'FontSize', fontsize);
  end
  sty = '-';
  if (nCols(tasks) >= 3), sty = tasks{i,3}; end
  fprintf(1, '%d: '); 
  line([span(1) span(2)], (n-i) * [1 1], 'LineWidth', 1, 'Color', 'k');
  line([dt(i,1)  dt(i,2)], (n-i) * [1 1], ...
      'LineStyle', sty, 'LineWidth', 4);
end
set(gca, 'YTick', [], 'XTick', [])

% Image the vertical lines.
x = span(1) : 365/div : span(2);	% if broken, try toggling these lines
% x = span(1) : 365.25/div : span(2);
%line([x;x], repmat([0;n-1], 1, length(x)), 'LineWidth', 1, 'Color', 'k')
for xi = x
  dv = datevec(xi);
  if (dv(2) == 1 || dv(2) == 12)
    line([xi xi], [0 n-0+0.1], 'LineWidth', 2, 'Color', 'k')
  else
    line([xi xi], [0 n-1+0.1],   'LineWidth', 1, 'Color', 'k')
  end
  % Image the Q1/Q2/Q3/Q4 labels or month labels.
  %qnum = mod1(round((mod(xi,365.2425))/365*div + 1), div); nm = ; % quarters
  qnum = mod1(round((mod(xi,365.2425))/365*div + 1), div);
  nm = iff(div == 4, ['Q' num2str(qnum)], months{qnum});
  if (xi ~= x(end))
%     text(xi + 365/(div*2),  -0.1, nm, 'Horiz','center', 'Vert','top');
    text(xi + 365/(div*2),  0.05, nm, 'Horiz','center', 'Vert','top');
  end
end


% Horizontal labels.
for y = yearlabels
  mid = mean([max(datenum(y,1,1), span(1))  min(datenum(y,12,31), span(2))]);
  text(mid, n-0.5, sprintf('%d', y), 'Horiz', 'center', 'Vert', 'bottom', ...
      'FontWeight', 'bold');
end

ylims(-1.0, n+0.5)
xlims(span(1) - 30.4*(textleft+2), span(2) + 30.4)

if (~any(outdir(end) == '/\')), outdir = [outdir filesep]; end
set(gca, 'pos', [0 0 1 1])
axis off
% wysiwyg
print('-dpng', [outdir 'timeline.png']);
