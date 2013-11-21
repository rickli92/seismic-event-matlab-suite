function plot_picks(w,varargin)

%PLOTM2: Plot Multiple Waveforms

%%

%mscale = where I left off

w = filt(w,'bp',[.5 15]);
w = demean(w);
w = w./mean(abs(w)); % scale waveforms
fh = figure;
ax = axes;
nw = numel(w);
sp = 10;          % trace spacing
fill = 0;        % don't area fill bottom half of waveform
xl = max(get(w,'data_length')./get(w,'freq'));
ylabtype = 'sta:chan';

%%
if (nargin > 1)
   v = varargin;
   nv = nargin-1;
   if ~rem(nv,2) == 0
      error(['plotm2: Arguments after wave must appear in ',...
             'property name/val pairs'])
   end
   for n = 1:2:nv-1
      name = lower(v{n});
      val = v{n+1};
      switch name
         case 'scale' % Event Start/Stop Times
            if isnumeric(val) && numel(val)==1
               sp = sp/val; % Where I left off...
            end
            
         case 'fill' % Trace Fill
            fill = val;
         case 'ylab' % Y-Tick Spacing
            ylabtype = val;   
         otherwise
            error('plotm2: Property name not recognized')
      end
   end
end

%%
warning off
for n = 1:nw
   cl(n) = -n*sp;   % trace center line
   tv = get(w(n),'timevector');
   start = get(w(n),'start');
   d2s = 24*60*60;
   dat = get(w(n),'data');
   if fill~=0
      area((tv-start)*d2s,dat+cl(n),cl(n),'LineWidth',1)
      if n==1, hold on, end
      off = min(dat);
      area((tv-start)*d2s,dat+cl(n),-nw*sp*2,'FaceColor',[1 1 1])
   else
      plot((tv-start)*d2s,dat+cl(n),'Color',[0 0 0])
      if n==1, hold on, end
      try scatter((get(w(n),'p_datenum')-start)*24*60*60,cl(n),'*','r'), catch, end
      try scatter((get(w(n),'s_datenum')-start)*24*60*60,cl(n),'*','g'), catch, end
   end
   ypos(n)=cl(n);
   switch ylabtype
      case 'time'
         ylab{n}=datestr(start);
      case {'station','sta'}
         ylab{n}=get(w(n),'station');
      case {'station-channel','station:channel','station/channel',...
            'sta-chan','sta:chan','sta/chan','stachan'}
         ylab{n}=[get(w(n),'station'),':',get(w(n),'channel')];
         if n==1, title(datestr(start)), end
   end
end
ypos=ypos(end:-1:1);
ylab=ylab(end:-1:1);
set(ax,'YTick',ypos,'YTickLabel',ylab)
ylim([cl(end)-2*sp cl(1)+2*sp])
xlim([0 xl])
xlabel('Time (s)')
warning on









