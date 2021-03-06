pro sd_fft

	; Open the fit index file and load it into the inx structure

	set_plot,'PS',/copy
	device,/landscape,/COLOR,BITS_PER_PIXEL=8

	erase

  inp=FitOpen('/data/fit/20110218.fhe.fitex',/read)

	x_arr = dblarr(100000)
	my_arr = dblarr(100000)
	n = 0L
	first = 1

	year=2011
	mon = 2
	day = 18

	gate = 27
	sthr = 2
	stmin=30
	edhr=3
	edmin=15

	channel = 0

	sttime = JULDAY(mon, day, year, sthr, stmin, 0)

	edtime = JULDAY(mon, day, year, edhr, edmin, 0)

  while FitRead(inp,prm,fit) ne -1 do begin
		cur_time = JULDAY(prm.time.mo, prm.time.dy, prm.time.yr, prm.time.hr, prm.time.mt, prm.time.sc)
     if(cur_time ge sttime AND cur_time lt edtime AND prm.channel eq channel AND prm.bmnum eq 7) then begin
				if(fit.qflg[gate] AND abs(fit.v[gate]) lt 200) then begin
					if(first eq 1) then begin
						st_time = JULDAY(prm.time.mo, prm.time.dy, prm.time.yr, prm.time.hr, prm.time.mt, prm.time.sc)
						first = 0
					endif
					my_arr(n) = fit.v[gate]
					cur_time = JULDAY(prm.time.mo, prm.time.dy, prm.time.yr, prm.time.hr, prm.time.mt, prm.time.sc)
					x_arr(n) = (cur_time - st_time)*86400
					n = n+1
				endif
     endif
  endwhile

  free_lun,inp

	my_arr = reform(my_arr(0:n-1))
	x_arr = reform(x_arr(0:n-1))

	my_arr = my_arr - mean(my_arr)

	n_samp = round(x_arr(n-1))
	points = findgen(n_samp)

	res = interpol(my_arr,x_arr,points)
	han = hanning(n_samp)


	my_psd = fft(res*han,1)

	pos_psd = reform(my_psd(0:n_samp/2-1))

	plot,findgen(n_samp/2-1)/(n_samp),(abs(pos_psd)^2),xrange=[0,.03],xstyle=1,/noerase

	max_psd = max(pos_psd,max_s)

	freq = double(max_s)/double(n_samp)
	print,freq

	erase

	plot,x_arr,my_arr,yrange=[-200,200],ystyle=1,xrange=[0,n_samp],xstyle=1,ytitle='velocity',xtitle='seconds',/noerase,pos=[.1,.55,.9,.9]

	x = findgen(n_samp)
	v = 100.*sin(x*freq*2.*!pi)

	plots,x,v

  plot,points,res*han,yrange=[-200,200],ystyle=1,xrange=[0,n_samp],xstyle=1,ytitle='velocity',xtitle='seconds',pos=[.1,.1,.9,.45],/noerase

	erase
	
	print,n_samp
	;close the postscript file
  if(!d.name eq 'PS') then  device,/close



end