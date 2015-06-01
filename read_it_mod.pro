PRO read_it, grid, filename, OPTION

;this program reads the file created by 'box_it.pro' and sums the flux over your channel range
;created by Nicholas Crump and Jessica Rosenberg, George Mason University, Jan 2010

;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*==*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
;					INTRO FOR NEW USERS
;This program works with the program 'box_it.pro' which allows users to display contour plots
;of their data in order to box and save the good stuff. This program reads the
;original grid and the data file created by  
;'box_it.pro' (given its filename by the user at the end of that program session) to serve two functions based 
;on the user's input OPTION at runtime. 
;
;For 'OPTION' = 1: this program plots each channel of data in 'newarr' one channel at a time in order to see the 
;	saved data in the array. In this option, a LEFT mouse click proceeds to the next channel; a RIGHT mouse 
;	click ends the session. 
;For 'OPTION' = 0: this program creates and plots the array sum called 'sumarr' which is a 2-dimensional [144x144] 
;	array containing only the x,y values summed over all of the channels in the original array ('newarr'). At 
;	the end of this session you will be given the option to save the data that was created and assign a file name. 
;	Your saved file will contain the following variables:
;
;	'sumarr' - 2-dimensional [144x144] array of flux data summed over your channel range
;	'newarr' - your 4-dimensional [channel_rangex1x144x144] array containing the good data that was boxed
;	'ra' - 1-dimensional [144] array of ra values corresponding to your grid
;	'dec' - 1-dimensional [144] array of dec values corresponding to your grid
;	'xmin','xmax','ymin','ymax' - ra/dec min/max values from your plot window (or values that you input, noted below)
;	'levels' - contour levels carried through from 'box_it.pro'
;	'channel_start' and 'channel_end' - beginning and ending channels that you boxed
;	'channelarr' - 1-dimensional array containing the list of channels that correspond to your data in 'newarr'
;	'velocity_start' and 'velocity_end' - corresponding beginning and ending velocities
;	'velocityarr' - 1-dimensional array containing the list of velocities that correspond to the channels
;	'size_x'-x-axis pixel size of grid
;	'size_y'-y-axis pixel size of grid

;make sure to enter the filename with double quotes around it like this: "filename.sav"
;to call this procedure: 
;			read_it, grid, "box_it_data.sav", 0
;					or
;			read_it, grid, "mydata.sav", 1

;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
;areas of the code that can be adapted by the user are placed in a box like this and are as follows:
;	-lines 77-80: choose to plot over entire RA/DEC window
;	-lines 88-91: choose to zoom plot into specified window
;	-lines 121 & 124: choose to plot in pixel coords or RA/DEC coords for OPTION = 0
;	-lines 191-192 & 195-196: choose RA/DEC plot labels for OPTION = 1
;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
;	
;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*==*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*= 

;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
; access variables from 'filename' to set up plot window
;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
;restore your file containing 'newarr'
restore, filename

;set background color to white/ plot color to black
!p.background=255
!p.color=0

;get some information about 'newarr' using the 'size' function
;'size(newarr)' gives a few properties of the array such as: # dimensions, # elements & dimension, etc
;'props' is an array of properties corresponding to 'newarr'
props=size(newarr)
;get dimensions, channel_range, and x,y size of 'newarr'
dimensions=props[0]
chann_range=props[1]
size_x=props[3]
size_y=props[4]

;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*
; set up variables for contour plotting
;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
;**set x,y pixel range for plotting in pixel coordinates**
xrange=[size_x,0]
yrange=[0,size_y]

;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
;set RA,DEC range for plotting in RA/DEC coordinates
;note: this plots over entire RA/DEC range; to zoom in on an area, change values in lines 74-77 below
xmin=ra[0]
xmax=ra[size_x-1]
ymin=dec[0]
ymax=dec[size_y-1]
;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
;alternate max/min values to zoom in on an area
;note: if using these, uncomment below on lines 85-88, enter your values and comment the above
;enter these values as float values for RA hour and ;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
; create contour overlay onto image
;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=DEC degrees, for example an RA of 08h58m12s would be 8.97, and DEC of 13d33m00s would be 13.55
;the code will then do the conversion to 00h00m00s RA and 00d00m00s DEC
;xmin=9.04
;xmax=9.06
;ymin=13.1
;ymax=13.4
;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

x=findgen(size_x)
y=findgen(size_y)

levels = levels

;get channel/velocity range information to display in plot window
channel_start=channel_start
channel_end=channel_start+channel_range
velocity_start=round(velocityarr[0])
velocity_end=round(velocityarr[channel_range])

;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
; enter OPTION 1 procedure:
;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
;this plots data for individual channels in 'newarr' as long as the mouse click is a LEFT click
;a contour plot is generated for each channel and loops through the entire channel range 

;reset mouse click
!mouse.button=0

if (OPTION eq 1) then begin
  for step = 0, chann_range-1 do begin

    if (!mouse.button NE 4) then begin 
    
      ;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
      ;**this plot in pixel coordinates**
      ;contour, newarr[step,0,x,y], levels=levels, xrange=xrange, yrange=yrange, xstyle=1, ystyle=1
      
      ;**this plots in RA/DEC coordinates**
      contour,newarr[step,0,x,y],ra,dec,xrange=[xmax,xmin],yrange=[ymin,ymax],levels=levels
      ;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
      
      xyouts, 0.12, 0.87, "channel:", charsize=1.4, charthick=1, /normal
      xyouts, 0.16, 0.87, floor(channelarr[step]), charsize=1.4, charthick=1, /normal
      xyouts, 0.30, 0.87, "of", charsize=1.4, charthick=1, /normal
      xyouts, 0.25, 0.87, floor(channelarr[channel_range]), charsize=1.4, charthick=1, /normal
      
      xyouts, 0.12, 0.84, "velocity:", charsize=1.4, charthick=1, /normal
      xyouts, 0.16, 0.84, floor(velocityarr[step]), charsize=1.4, charthick=1, /normal
      xyouts, 0.30, 0.84, "of", charsize=1.4, charthick=1, /normal
      xyouts, 0.25, 0.84, floor(velocityarr[channel_range]), charsize=1.4, charthick=1, /normal
      cursor, c1,c2, /down
    endif

    if (step eq chann_range-1) then begin
      print, "****FINISHED****"
      print, ""
    endif
      
  endfor
endif else begin

;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
; enter OPTION 0 procedure:
;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
;this is where 'sumarr' is created to hold the summed x,y values of 'newarr' across the channel range

    ;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
    ; get the scaling for the image
    ;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=    

    scaling=abs((velocity_start-velocity_end)/(channel_start-channel_end))
    nu_mid = 1.4204058-(((velocity_start+velocity_end)/2.0)/2.9989e5)*1.4204058
    nHI_scale = 2.228e21/(198.*228.*nu_mid*nu_mid)

    ;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
    ; get variables for the total beam 
    ;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=    
        
    llx = 0
    lly = 0
    urx = 143
    ury = 143
	
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
    
    ;get the beam size this is important for the fluxbox routine but not 
    ;for getting a moment 0 map.
    ;When you sum the data you get mJy/beam. To derive the flux you are then
    ;summing over a number of pixels for your source so you need to multiply
    ;by beam/pix or divide by pix/beam which is what this is getting you
    
    bxarr=deltaram*(findgen(nbx)-mean(findgen(nbx)))
    byarr=grid.deltadec*(findgen(nby)-mean(findgen(nby)))
    bxarr=rebin(bxarr,nbx,nby)
    byarr=reform(byarr,1,nby)
    byarr=rebin(byarr,nbx,nby)
    beam=exp(-0.5*(bxarr/sigmax)^2)*exp(-0.5*(byarr/sigmay)^2)
    totbeam=total(beam)
    
    ;levels = levels
    
    levels = levels*nHI_scale*scaling

    print,levels

sumarr = total(newarr,1)*nHI_scale*scaling
;sumarr = total(newarr,1)
help,sumarr

;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
; Convert RA/DEC into the form 00h00m00s/00d00m00s
;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
window, /free, xsize=900, ysize=900

;**this plots in RA/DEC coordinates**
contour,sumarr,ra,dec,xrange=[xmax,xmin],yrange=[ymin,ymax],levels=levels, /nodata, xtick_get=xaxislabel, ytick_get=yaxislabel

;Create RA labels in the form: "00h00m00s"
nlabels=n_elements(xaxislabel)
for i=0, nlabels-1 do if (xaxislabel[i] lt 0) then xaxislabel[i]=xaxislabel[i]+24

rahour=floor(xaxislabel)
raminute=floor((xaxislabel-rahour)*60)
rasecond=round(((xaxislabel-rahour)*60-raminute)*60)
xlabels=strarr(nlabels)

for i=0, nlabels-1 do xlabels[i]=string(rahour[i],format='(i2)')+'h'+string(raminute[i],format='(i2)')+'m'+string(rasecond[i],format='(i2)')+'s'

;Create DEC labels in the form: 00d00m00s
nlabels=n_elements(yaxislabel)
decdegree=floor(yaxislabel)
decminute=floor((yaxislabel-decdegree)*60)
decsecond=round(((yaxislabel-decdegree)*60-decminute)*60)

ylabels=strarr(nlabels)

for i=0, nlabels-1 do ylabels[i]=string(decdegree[i],format='(i2)')+'d'+string(decminute[i],format='(i2)')+'m'+string(decsecond[i],format='(i2)')+'s'

;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
;plot final image with RA/DEC labels and window placement adjusted
;NOTE: use this contour command to plot the contours with RA/DEC axis labels in the form RA "00h00m00s" and DEC "00d00m00s"
contour,sumarr,ra,dec,xrange=[xmax,xmin],yrange=[ymin,ymax],levels=levels, xtickname=xlabels, ytickname=ylabels, $
xtitle='!6 Right Ascension (hour)',ytitle='Declination (degree)', position=[.15,.15,.85,.85], charsize=1.5

;NOTE: use this contour command to plot the contours with RA/DEC axis labels in decimal form such as 8.97 or 13.55
;contour,sumarr,ra,dec,xrange=[xmax,xmin],yrange=[ymin,ymax],levels=levels, $
;xtitle='!6 Right Ascension (hour)',ytitle='Declination (degree)', position=[.15,.15,.85,.85], charsize=1.5
;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
  
;display channel range label on plot
xyouts, 0.12, 0.89, "channels:", charsize=1.5, charthick=1, /normal
xyouts, 0.18, 0.89, channel_start, charsize=1.2, charthick=1, /normal
xyouts, 0.24, 0.89, "-", charsize=1.2, charthick=1, /normal
xyouts, 0.22, 0.89, channel_end, charsize=1.2, charthick=1, /normal

;display velocity range label on plot
xyouts, 0.12, 0.86, "velocities:", charsize=1.5, charthick=1, /normal
xyouts, 0.16, 0.86, velocity_start, charsize=1.2, charthick=1, /normal
xyouts, 0.25, 0.86, "-", charsize=1.2, charthick=1, /normal
xyouts, 0.21, 0.86, velocity_end, charsize=1.2, charthick=1, /normal

;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
; enter option to save image and variables that were created
;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
;to save variables to a file
print, ""
print, "------------FILE SAVE MENU------------"
filesave = ''
read,'Would you like to save this data to a file? (y/n)', filesave
if (filesave eq 'y') then begin
  read,filename, prompt = 'Enter a name for your file in the form filename.sav :'
  save, sumarr,ra,dec,xmax,xmin,ymax,ymin,levels,channel_start,channel_end,velocity_start,velocity_end,size_x,size_y, filename=filename
  print, "		**File Saved**"
endif

;to save image as 24-bit tif
print, ""
print, "------------IMAGE SAVE MENU------------"
imgsave = ''
imgfilename = ''
read,'Would you like to save this image? (y/n)', imgsave
if (imgsave eq 'y') then begin
  print, ""
  print, "NOTE: this may take a few moments as it is saving an uncompressed 24-bit tif image"
  print, ""
  read,'Enter a name for your image in the form filename.tif :',imgfilename
  imagevar=screenread(depth=depth)
  write_tiff,imgfilename,reverse(imagevar,3),1
  print, "		**Image Saved**"
endif

endelse

END
