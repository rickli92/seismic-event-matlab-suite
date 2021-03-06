
%% STA/LTA Little Sitkin

scnl(1) = scnlobject('LSSA','SHZ','AV');
scnl(2) = scnlobject('LSPA','SHZ','AV');
scnl(3) = scnlobject('LSNW','SHZ','AV');
scnl(4) = scnlobject('LSSE','SHZ','AV');

f = fullfile('C:','Work','Little_Sitkin','Single_Station_Detection');
cd(f);
%host = 'avowinston01.wr.usgs.gov';
host = 'pubavo1.wr.usgs.gov';
port = 16022;
t_start = datenum([2012 9 20 0 0 0]);
t_end = datenum([2012 9 20 0 0 0]);
edp = [1 8 2 1.6 0 0];
ds = datasource('winston',host,port);

for n = 4%1:numel(scnl)
    for day = t_start:t_end % Range to detect
        disp(['Currently looking at ', get(scnl(n),'station'),':',...
            get(scnl(n),'channel'),' on ',datestr(day)])
        disp('fetching waveform')
        w = get_w(ds,scnl(n),day,day+1);
        if ~isempty(w)
            w = filt(w,'bp',[1 10]);
            w = zero2nan(w,5);
            disp('detecting events')
            ev = sta_lta(w,'edp',edp,'lta_mode','grow','eot','wfa');
            if ~isempty(ev)
                E.wfa = ev;
                disp('computing metrics')
                E.rms = rms(E.wfa);
                E.pa = peak_amp(E.wfa,'val');
                E.p2p = peak2peak_amp(E.wfa,'val');
                E.pf = peak_freq(E.wfa,'val');
                E.fi = freq_index(E.wfa,[1 3],[8 15],'val');
                E.mf = middle_freq(E.wfa,'val');
                disp('saving structure')
                cd(fullfile(f,get(scnl(n),'station'),'event_structure'))
                save([datestr(day,29),'.mat'],'E')
                disp('building helicorder')
                fh = build(helicorder(w,'mpl',30,'e_sst',wfa2sst(E.wfa)));
                set(fh,'PaperType','A','PaperOrientation','portrait',...
                    'PaperUnits','normalized','PaperPosition',[0,0,1,1])
                print(fh, '-dpng', fullfile(f,get(scnl(n),'station'),...
                          'Helicorder',datestr(day,29)))
                close(fh)
                clear E w
                pack
            else
                disp(['No events detected from ', get(scnl(n),'station'),...
                    ':', get(scnl(n),'channel'),' on ',datestr(day)])
                E.wfa = waveform();
                E.rms = [];
                E.pa = [];
                E.p2p = [];
                E.pf = [];
                E.fi = [];
                E.mf = [];
                disp('saving structure')
                cd(fullfile(f,get(scnl(n),'station'),'event_structure'))
                save([datestr(day,29),'.mat'],'E')
                disp('building helicorder')
                fh = build(helicorder(w,'mpl',30));
                set(fh,'PaperType','A','PaperOrientation','portrait',...
                    'PaperUnits','normalized','PaperPosition',[0,0,1,1])
                print(fh, '-dpng', fullfile(f,get(scnl(n),'station'),...
                          'Helicorder',datestr(day,29)))
                close(fh)
                clear E w
                pack
            end
        else
            disp(['No waveform available for ', get(scnl(n),'station'),...
                ':', get(scnl(n),'channel'),' on ',datestr(day)])
        end
    end
end

%%
coverage = [];
f = fullfile('C:','Work','Iliamna','Single_Station_Detection');
t_start = datenum([2005 11 1 0 0 0]);
t_end = datenum([2012 2 20 0 0 0]);
for day = t_start:t_end % Range to detect
    if exist(fullfile(f,'ILW','Event_Structure',[datestr(day,29),'.mat']),'file')
        coverage = [coverage; day, 1];
    else
        coverage = [coverage; day, 0];
    end
end
    
    


