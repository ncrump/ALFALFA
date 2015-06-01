PRO BOX_IT, datacube, channel_start, channel_range, channel_boxcar, level_scale

;this program makes contour plots for specified channels in a grid datacube
;and allows for the user to box the good data and write it to a new array

;adopted from slice_it.pro written by Tom Balonek, Colgate University, current version 2007 May 08
;created by Nicholas Crump and Jessica Rosenberg, George Mason University, Jan 2010

;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*==*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
;					INTRO FOR NEW USERS
;This program is intended to reduce noise and unwanted data from contour plots by allowing the user to manually 
;extract and save only the data chosen to be 'good'. The program takes input parameters described below to 
;generate contour plots over a specified channel range. Plots are displayed one channel at a time and you are
;prompted to click inside the plot window to define lower-left and upper-right corners in which to draw your
;box around data that you would like to save. After boxes are drawn, a right click shows you only the data that
;will be saved and written to a new array. (Note: contour plots display the smoothed data according to your 
;boxcar & levelscale settings. The data that is saved to a new array at the end of the program, however, will be
;the original, unsmoothed data.) If boxes look good, you can choose to proceed to the next channel; if you
;make a mistake you can choose to redisplay the plot and rebox your data. When you finish, you will be prompted to 
;input a filename and all of the boxed data for each channel will be saved to that file which will contain 
;the following variables: 
;	'newarr' - your 4-dimensional [channel_rangex1x144x144] array  containing the good data that was boxed
;	'channelarr' - 1-dimensional array containing the list of channels that correspond to your data in 'newarr' 
;	'velocityarr' - 1-dimensional array containing the list of velocities that correspond to the channels
;	'channel_start' and 'channel_range' that you input at start
;	'ra'-1-dimensional [144] array of ra values corresponding to your grid
;	'dec'-1-dimensional [144] array of dec values corresponding to your grid
;	'levels'-contour levels 
;	'size_x'-x-axis pixel size of grid
;	'size_y'-y-axis pixel size of grid

;to call this procedure, 
; be sure to first restore your grid: restore,'gridbf_0900+13b.sav'
; then:     box_it,grid,765,10,2,1.0
;  or       box_it,grid,765,5,1,1.0

; datacube is passed the grid structure from ALFALFA drift data
; channel_start is the user-defined starting channel to plot
; channel_range is the number of channels away from the starting channel to plot
; channel_boxcar is averaging done over selected channels
; level_scale is the contour sensitivity
;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*==*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=   

;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
; create and set parameters for a new window for graphs
;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
;set background color to white/ plot color to black
!p.background=255
!p.color=0

;activate indexed color model
device,decomposed=0
loadct,0

;introduce window size variables 
window_xsize = 900
window_ysize = 900
window_size_ratio = float(window_ysize) / float(window_xsize)

;display blank window sized to set parameters
window,/free,xsize=window_xsize,ysize=window_ysize
window_index = !d.window
print,'window_index: ', window_index

plot_size = 0.18
inbox_label_size = 1.3
inbox_label_thick = 2

;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
; get ratio of character width/height to window width/height
;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
window_character_xsize = float(!d.x_vsize)
window_character_ysize = float(!d.y_vsize)

;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
; set up right ascension & declination and redshift indices for the datacube size
;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
;when program is called, the datacube parameter is passed the grid structure
;get RA/DEC here from datacube structure parameters
ra=datacube.ramin+(dindgen(n_elements(datacube.d[0,0,*,0]))+0.5)*datacube.deltara/3600.
dec=datacube.decmin+(dindgen(n_elements(datacube.d[0,0,0,*]))+0.5)*datacube.deltadec/(60.)

;the items nx, ny, nz are long/integer variables within the grid structure -
;they are accessed and stored to size variables
;Note: grid.nx and grid.ny are single-valued variables = 144
;grid.nz is a single-valued variable = 1024
size_x = datacube.nx
size_y = datacube.ny
size_z = datacube.nz

xrange = [size_x,0]
yrange  =[0,size_y]

;create index arrays of size nx, ny, nz accessed from the grid structure
x=findgen(size_x)
y=findgen(size_y)
z=findgen(size_z)

;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
; MAKE CONTOUR PLOTS
;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
;set the contour levels - right now it is set at levels which show modest noise
if (channel_boxcar eq 1) then begin
  ;levels = [5, 7.5, 10, 15, 20, 30, 40, 50] * level_scale
   levels = [6.5, 10, 15, 30, 50, 100, 130, 250] * level_scale
endif else begin
   levels = [6.5, 10, 15, 30, 50, 100, 130, 250] * level_scale $
                              / sqrt(float(channel_boxcar) / 2.0)
endelse

;create double-precision zero array with suitable dimensions in order to populate with data
;this array will contain the unsmoothed data indexed from arr by cursor clicks
;note: in the end this array is the one saved with the good data
newarr=dblarr(channel_range+1,1,size_x,size_y)

;create another zero array with suitable dimensions only for purposes of plotting smoothed (boxcar) data
;this array is used only for plotting the smoothed version of the "good" data that was boxed for user to see
;note: in the end this array is thrown away and newarr is the good one to keep
newplotarr=dblarr(1,1,size_x,size_y)

;get the weights from the grid.w array in the grid structure that go with the data values in the grid.d array
;note: both grid.d and grid.w are 4-dimensional arrays of dimension [1024,2,144,144]
;wgrid gets the weight values from grid.w and creates the average weights for each of the two polarizations
;weightedARR multiplies the grid.d data values by their respective weights and averages over the polarizations
wgrid = total(datacube.w,2)
weightedARR = ((datacube.d[*,0,*,*]*datacube.w[*,0,*,*])+(datacube.d[*,1,*,*]*datacube.w[*,1,*,*]))/wgrid

channelarr=dblarr(channel_range+1)
velocityarr=dblarr(channel_range+1)

option = 0

;****enter for loop to step through channel range****
;if option=2, the step is reset so that the same plot is displayed for the user to rebox data
;if option=3, the program breaks out of the loop and terminates by the user's choice
for step = 0, channel_range do begin
  if (option eq 2) then step = step-1
  if (option eq 3) then break
  channel = channel_start + step
  velocity=datacube.velarr(channel)

  channelarr[step]=channel
  velocityarr[step]=velocity
  
  ;note: arr is a 4-dimensional array of dimensions [1,1,144,144]
  ;this array will contain the unsmoothed data from which to index and populate newarr
  arr = weightedARR[channel,0,x,y]
  
  ;this array will contain the smoothed (boxcar) data only for purposes of plotting
  ;note: plotarr is same dimensions as arr
  plotarr=arr

  ;this is where the smoothing happens
  if (channel_boxcar ne 1) then begin
    channel_boxcar_min = fix(channel - floor((channel_boxcar - 1) / 2.0))
    channel_boxcar_max = fix(channel +  ceil((channel_boxcar - 1) / 2.0))
    plotarr = plotarr * 0.0
    for chann = channel_boxcar_min, channel_boxcar_max do begin
	plotarr = plotarr + (((datacube.d[chann,0,x,y] + datacube.d[chann,1,x,y]) / 2.0) $
		    / float(channel_boxcar))
    endfor
  endif

  ;make contour plot of plotarr (which is the smoothed version of arr)
  contour, plotarr[0,0,x,y], levels=levels, xrange=xrange, yrange=yrange, xstyle=1, ystyle=1

  ;list channel/velocity parameters within plot window
  label_vel = string(round(velocity),format='(i4)')
  xyouts, 0.10, 0.90, 'velocity:', charsize=1.5, charthick=1, /normal
  xyouts, 0.17, 0.90, label_vel, charsize=1.5, charthick=1,  /normal
  xyouts, 0.10, 0.87, 'channel:', charsize=1.5, charthick=1, /normal
  xyouts, 0.13, 0.87, channel, charsize=1.5, charthick=1, /normal

  ;list some parameters at bottom of page
  contour_levels_text = string ('contour levels:',levels, format='(a15,10f6.1)')
  xyouts, 0.055, 0.01, 'boxcar:', /normal
  xyouts, 0.057, 0.01, channel_boxcar, /normal
  xyouts, 0.15, 0.01, contour_levels_text, /normal
  xyouts, 0.60, 0.01, datacube.name, /normal
  xyouts, 0.70, 0.01, 'box_it', /normal
  date=systime()
  xyouts, 0.80, 0.01, date, /normal

;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
; enter while loop to draw boxes around good data
;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
  ;reset mouse click
  !mouse.button=0

  ;make box plots as long as mouse click is not a right click
  ;get box coordinates and draw box:
  while (!mouse.button NE 4) do begin
    print, ""
    print, '**************************************************'
    print, 'The following steps create a box around good data:'
    print, "    RIGHT CLICK IN WINDOW WHEN FINISHED BOXING"
    print, "             Be sure to have fun!            "
    print, '**************************************************'
    print, ""
    print, 'Click in window to select LOWER-LEFT box corner'
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
	
    x1 = floor(xtmp1)
    y1 = floor(ytmp1)
    x2 = floor(xtmp2)
    y2 = floor(ytmp2)
    plots,[x1,x1,x2,x2,x1], [y1,y2,y2,y1,y1]
    
    ;populate newplotarr with data indexed from plotarr only for plotting smoothed data to see
    newplotarr[0,0,x2:x1,y1:y2]=plotarr[0,0,x2:x1,y1:y2]

    ;populate newarr with data indexed from arr passed from cursor clicks
    ;this maintains the order of the data in newarr as it is in arr
    newarr[step,0,x2:x1,y1:y2]=arr[0,0,x2:x1,y1:y2]
    
  endwhile
;****end while loop for boxing good data****

  ;make contour plot of data that was boxed and determined to be good
  ;note: this plots the unsmoothed data in order to see what you are getting
  contour, newplotarr[0,0,x,y], levels=levels, xrange=xrange, yrange=yrange, xstyle=1, ystyle=1 

;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
; enter option menu
;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
  option = 0
  print, ""
  print, "------------OPTION MENU------------"
  print, 1, ":Proceed to the next plot"
  print, 2, ":Erase boxes and try again"
  print, 3, ":End program"
  read,option, prompt = 'Select a number from the above OPTION MENU:'
  print, ""
  
  ;user is caught in this while loop when invalid entry is made on option menu
  while (option ne 1 and option ne 2 and option ne 3) do begin
    print, "!!!!!!!!!!--INVALID ENTRY--!!!!!!!!!!" 
    print, ""
    print, "------------OPTION MENU------------"
    print, 1, ":Proceed to the next plot"
    print, 2, ":Erase boxes and try again"
    print, 3, ":End program"
    read,option, prompt = 'Select a number from the above OPTION MENU:'
    print, ""
  endwhile

  case option of
    1: begin
	;zero out newplotarr to start over
	newplotarr=newplotarr*0
	print, "PREVIOUS CHANNEL NUMBER:", channel
	print, "" 

	;this program finishes here once we loop through the entire channel range
	;the user is prompted to input a filename below and the variables are saved to that file
	if (step eq channel_range) then begin
	  filename = ""
	  print, "****PROCEDURE FINISHED****
	  print, "****NOW SAVE YOUR DATA****"
	  print, ""
	  read,filename, prompt = 'Enter a name for your file in the form filename.sav :'
	  save, newarr, channelarr, velocityarr, channel_start, channel_range, ra, dec, levels, size_x, size_y, filename=filename
	  print, ""
	  print, ""
	  print, "****************************************************"
	  print, "****************************************************"
	  print, "     DATA SAVED to filename:", filename
	  print, ""
	endif
      end

    2:begin
	;zero out newplotarr to start over
	newplotarr=newplotarr*0
	;also zero out data in newarr only for the current step since it was already populated-
	;when the mouse clicks were made and boxes drawn
	newarr[step,0,0:size_x-1,0:size_y-1]=newarr[step,0,0:size_x-1,0:size_y-1]*0
	print, ""
	print, "------------------------------------------"
	print, "PLEASE REDRAW YOUR BOXES AROUND GOOD DATA"
	print, "------------------------------------------"
      end
    
    3:begin
	;this ends the program without saving data
	print, ""
	print, "**PROGRAM ENDED**"
	print, ""
	break
      end
  endcase
endfor
;****end for loop that looped through channel range***

END
