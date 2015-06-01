PRO fluxbox, grid, filename

;this program displays the array sum created by 'read_it.pro' and calculates the flux within a specified contour region
;created by Nicholas Crump and Jessica Rosenberg, George Mason University, May 2010

;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*==*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
;					INTRO FOR NEW USERS
;This program works with the program 'read_it.pro' which creates the array sum of data in a grid that was 
;boxed using 'box_it.pro'. This program displays a contour plot of the array sum and allows the user to calculate
;the flux within a specified box region by clicking lower-left and upper-right points to define their flux box.
;After a box is plotted, the flux value is printed in the IDL command window. A right click exits the program.

;be sure to first restore your grid, then enter the filename with double quotes around it like this: "filename.sav""
;to call this procedure: 
;			fluxbox, grid, "read_it_data.sav"
;	
;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*==*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*= 

;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
; access variables from 'filename' to set up plot window
;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
;restore your file containing 'sumarr'
restore, filename

;set background color to white/ plot color to black
!p.background=255
!p.color=0

xrange=[size_x,0]
yrange=[0,size_y] 

;set the size of display window
window, /free, xsize=750, ysize=750

;plot the data (in pixel coordinates)
contour,sumarr,xrange=xrange,yrange=yrange,levels=levels

;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
; enter while loop to box contour regions of interest and get flux
;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
  ;reset mouse click
  !mouse.button=0

  ;make box plots as long as mouse click is not a right click
  ;get box coordinates and draw box:
  while (!mouse.button NE 4) do begin
    print, ""
    print, '***********************************************************************************'
    print, 'The following steps total the data values in a specified box region to get the flux'
    print, 'Follow the steps to click lower left and upper rights point to define your region'
    print, "    		RIGHT CLICK IN WINDOW WHEN FINISHED BOXING"
    print, '***********************************************************************************'
    print, ""
    print, 'Click in window to select LOWER-LEFT box corner'
    cursor, xtmp1, ytmp1, /down
    
    ;the following 'if' statements set the values of xtmp1 and ytmp1 to-
    ;the boundary of the plot area if the clicks fall outside the boundary
    if (floor(xtmp1) ge xrange[0]) then xtmp1 = xrange[0]-1
    if (floor(xtmp1) le xrange[1]) then xtmp1 = xrange[1]+1
    if (floor(ytmp1) ge yrange[1]) then ytmp1 = yrange[1]-1
    if (floor(ytmp1) le yrange[0]) then ytmp1 = yrange[0]+1

    print, "Coordinates = ",[floor(xtmp1), floor(ytmp1)]
    print, ""
    
    if (!mouse.button EQ 4) then break
    print, 'Click in window to select diagonal UPPER-RIGHT box corner'
    cursor, xtmp2, ytmp2, /data, /down

   ;the following 'if' statements set the values of xtmp2 and ytmp2 to-
   ;the boundary of the plot area if the clicks fall outside the boundary
    if (floor(xtmp2) ge xrange[0]) then xtmp2 = xrange[0]-1
    if (floor(xtmp2) le xrange[1]) then xtmp2 = xrange[1]+1
    if (floor(ytmp2) ge yrange[1]) then ytmp2 = yrange[1]-1
    if (floor(ytmp2) le yrange[0]) then ytmp2 = yrange[0]+1

    print, "Coordinates = ",[floor(xtmp2), floor(ytmp2)]
    print, ""
    
    ;enter while loop when box corners are not selected correctly
    ;such as selecting the first click out of sequence from the second click
    while (floor(xtmp1) lt floor(xtmp2) or floor(ytmp1) gt floor(ytmp2)) do begin
	print, "INVALID BOX CORNERS SELECTED!!"
	print, ""
	print, 'Click in window to select LOWER-LEFT box corner'
	print, ""
	cursor, xtmp1, ytmp1, /data, /down
	
	;the following 'if' statements set the values of xtmp1 and ytmp1 to-
	;the boundary of the plot area if the clicks fall outside the boundary
	if (floor(xtmp1) ge xrange[0]) then xtmp1 = xrange[0]-1
	if (floor(xtmp1) le xrange[1]) then xtmp1 = xrange[1]+1
	if (floor(ytmp1) ge yrange[1]) then ytmp1 = yrange[1]-1
	if (floor(ytmp1) le yrange[0]) then ytmp1 = yrange[0]+1

	print, "Coordinates = ",[floor(xtmp1), floor(ytmp1)]
	print, ""
	if (!mouse.button EQ 4) then break
	print, 'Click in window to select diagonal UPPER-RIGHT box corner'
	print, ""
	cursor, xtmp2, ytmp2, /data, /down

	;the following 'if' statements set the values of xtmp2 and ytmp2 to-
	;the boundary of the plot area if the clicks fall outside the boundary
	if (floor(xtmp2) ge xrange[0]) then xtmp2 = xrange[0]-1
	if (floor(xtmp2) le xrange[1]) then xtmp2 = xrange[1]+1
	if (floor(ytmp2) ge yrange[1]) then ytmp2 = yrange[1]-1
	if (floor(ytmp2) le yrange[0]) then ytmp2 = yrange[0]+1
	
	print, "Coordinates = ",[floor(xtmp2), floor(ytmp2)]
	print, ""
	 
    endwhile
	
    urx = floor(xtmp1)
    lly = floor(ytmp1)
    llx = floor(xtmp2)
    ury = floor(ytmp2)
    plots,[urx,urx,llx,llx,urx], [lly,ury,ury,lly,lly]
    
    ;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
    ; get variables for the flux calculation
    ;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=    
    ;get the difference in velocity dV between channels from grid.velarr
    ;this gets dV directly in the middle of the channel range
    midCH=channel_start+((channel_end - channel_start)/2)
    dV=grid.velarr[midCH]-grid.velarr[midCH+1]
    
    ;this is just to check the upper and lower bounds on dV
    ;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
    ;this gets dVhigh which is the upper bound on dV
    ;dVhigh=grid.velarr[channel_start]-grid.velarr[channel_start+1]
    ;print, "Upper dV is:", dVhigh
    ;this gets dVlow which is the lower bound on dV
    ;dVlow=grid.velarr[channel_end-1]-grid.velarr[channel_end]
    ;print, "Lower dV is:", dVlow
    ;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
    
    ;get stuff needed for the beam size and total line flux here
    nsx=urx-llx+1
    nsy=ury-lly+1

    rah=grid.ramin+(dindgen(n_elements(grid.d[0,0,*,0]))+0.5)*grid.deltara/3600.   
    dec=grid.decmin+(dindgen(n_elements(grid.d[0,0,0,*]))+0.5)*grid.deltadec/(60.) 
    decnr=dec[(lly+ury)/2.]
    cosdec=cos(decnr*!dpi/180.)
    deltaram=0.25*grid.deltara*cosdec  

    nbx=nsx
    nby=nsy

    beam=dblarr(nbx,nby)
    hpfwx=3.3
    hpfwy=3.8
    sigmax=0.42466*hpfwx
    sigmay=0.42466*hpfwy
    
    ;get the beam size
    bxarr=deltaram*(findgen(nbx)-mean(findgen(nbx)))
    byarr=grid.deltadec*(findgen(nby)-mean(findgen(nby)))
    bxarr=rebin(bxarr,nbx,nby)
    byarr=reform(byarr,1,nby)
    byarr=rebin(byarr,nbx,nby)
    beam=exp(-0.5*(bxarr/sigmax)^2)*exp(-0.5*(byarr/sigmay)^2)
    totbeam=total(beam)
    ;print, ""
    ;print, "The total beam size is ", totbeam
    ;print, ""
      
    ;get the total line flux
    TOTflux=(total(sumarr[llx:urx,lly:ury]))
    TOTflux=(((total(sumarr[llx:urx,lly:ury]))*dV)/totbeam)/1000
    print, "The flux in this region is ", TOTflux , " Jy km/s"
    
    ;this is just to get the upper and lower bound on the flux
    ;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
    ;TOTfluxhigh=(((total(sumarr[llx:urx,lly:ury]))*dVhigh)/totbeam)/1000
    ;print, "The Upper flux in this region is ", TOTfluxhigh , " Jy km/s"
    ;TOTfluxlow=(((total(sumarr[llx:urx,lly:ury]))*dVlow)/totbeam)/1000
    ;print, "The Lower flux in this region is ", TOTfluxlow , " Jy km/s"
    ;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
    
  endwhile
;****end while loop for boxing regions to get flux****

END