PRO firstmoment, filename

;this program creates an intensity-weighted velocity map (first moment) color-image with a contour overlay of a specified region
;created by Nicholas Crump and Jessica Rosenberg, George Mason University, June 2010

;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*==*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
;					INTRO FOR NEW USERS
;This program is intended to work with the programs 'box_it.pro' and 'read_it.pro'. This program uses the file 
;created by 'read_it.pro' to create an array holding the intensity-weighted velocities from your boxed contour
;data and plot them as a color-image with a corresponding contour overlay. 

;make sure to enter the filename with double quotes around it like this: "filename.sav"
;to call this procedure: 
;			firstmoment, "read_it_data.sav"

;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
;areas of the code that can be adapted by the user are placed in a box like this and are as follows:
;	-lines 84-87: choose contour plot window that you would like to view in pixel coordinates
;	-line 124: set the array index as the same values that you chose for the viewing window
;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*==*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=

;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
; access variables from 'filename' to set up plot window
;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
;restore your file from 'read_it.pro' containing 'newarr', 'sumarr', and other useful variables
restore, filename

;set up variables for contour plotting
;set x,y pixel range
xrange=[size_x,0]
yrange=[0,size_y]

;get channel & velocity range information
channel_range = channel_end - channel_start
channel_start = channel_start
channel_end = channel_start+channel_range-1
velocity_start = round(velocityarr[0])
velocity_end = round(velocityarr[channel_range-1])

;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
; calculate intensity-weighted velocity
;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
;this is where the intensity-weighted velocities are computed
;avgvelarr will hold the intensity-weighted velocities
;newsumarr will hold the total intensity values (ignoring negative intensities)
;nchanarr will hold the number of channels containing positive intensity data per pixel position
;note: all arrays are [144x144]
avgvelarr = dblarr(size_x,size_y)
newsumarr = dblarr(size_x,size_y)
nchanarr = intarr(size_x,size_y)

;do a triple 'for' loop to index 3-D array 
;get total intensity for newsumarr in each pixel
;get number of channels in each pixel that have positive intensity data for nchanarr
;get velocity*intensity for each pixel in each channel for avgvelarr
for i = 0, size_x-1 do begin
  for j = 0, size_y-1 do begin
    for k = 0, channel_range-1 do begin
      if (newarr[k,0,i,j] gt 0) then begin
      newsumarr[i,j] = newsumarr[i,j] + newarr[k,0,i,j]
      nchanarr[i,j] = nchanarr[i,j]+1
      avgvelarr[i,j] = avgvelarr[i,j] + velocityarr[k]*newarr[k,0,i,j]
      endif
   endfor
  endfor
endfor

;divide velocity*intensity by total intensity in each pixel (but don't divide by zero)
for i = 0, size_x-1 do begin
  for j = 0, size_y-1 do begin
    if (newsumarr[i,j] gt 0) then avgvelarr[i,j] = avgvelarr[i,j]/newsumarr[i,j]
  endfor
endfor

;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
;    Routine to obtain the total average velocity
;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
nvel=0
for i=0, size_x-1 do begin
  for j=0, size_y-1 do begin
    if (avgvelarr[i,j] ne 0) then nvel = nvel+1
  endfor
endfor
print, ""
print, "Number of pixels with velocity information:", nvel
vel=total(avgvelarr)
;print, vel
avgvel=vel/nvel
print, "Total Average Velocity:", avgvel
print, ""
;-------------------------------------------------------

;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
; set up contour plot
;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=

;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
;set contour plot window that you would like to view in pixel coordinates
;make changes here for viewing specified sections of your contour plot
xmin = 0
xmax = 40
ymin = 74
ymax = 120
;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

window, /free, xsize=750, ysize=750

;**this plots in RA/DEC coordinates
contour,sumarr,ra,dec,xrange=[ra[xmax],ra[xmin]],yrange=[dec[ymin],dec[ymax]],levels=levels,/nodata,xtick_get=xaxislabel,ytick_get=yaxislabel
erase

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

;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
; set up image display
;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
image = avgvelarr

;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
;index image array (avgvelarr) to match the xmin,xmax,ymin,ymax values that you specified in lines 84-87
image=image[0:40,74:120]
;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

image=reverse(image)
;resize image to fit display window
image=congrid(image,500,500)
;control image scaling
image=bytscl(image,min=3800,max=4300)
;load blue-red color table
loadct,33
;display image with offset to center in display window
tv,image,125,125

;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
; create contour overlay onto image
;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
;load contour color table
loadct,0
!p.color=0

;plot contour overlay
contour,sumarr,ra,dec,xrange=[ra[xmax],ra[xmin]],yrange=[dec[ymin],dec[ymax]],levels=levels,xtickname=xlabels,ytickname=ylabels, $
xtitle='!6 Right Ascension (hour)',ytitle='Declination (degree)',charsize=1.5,/noerase,position=[125,125,625,625],/device

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
  save, avgvelarr,newsumarr,nchanarr,filename=filename
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
  read,'Enter a name for your file in the form filename.tif :', imgfilename
  imagevar=screenread(depth=depth)
  write_tiff,imgfilename,reverse(imagevar,3),1
  print, "		**Image Saved**"
endif

END
