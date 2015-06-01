;NAME:
;	OVERLAY
;
;PURPOSE:
;        Overlay contour diagram on an image.	
;
;CALLING SEQUENCE:
;        overlay,grid,sumarr,ra,dec,levels,8.922,8.948,12.959,13.342,mosaicRD,channel_start,channel_end,velocity_start,velocity_end	
;
;OUTPUT:
;        Contour overlay on image which can then be saved via:
;        response=tvread(filename='contouroverlay',/JPEG,quality=100,/nodialog)
;
;NOTES:
;        This program cannot be used alone. There are two steps that need to be
;        done before you can use this program. First you must create the
;        contour then you must create the image. This program only overlays the
;        two on top of each other. To create the contour, use contourplot.pro
;        and to create the image, use montage. There is a well documented
;        webpage located at: 
;        file:///home/hatillo/galaxy/tess/overlay/makeoverlay.htm
;        Once the contour and image are created, make sure the grid, image and
;        contour overlay parameters are restored:
;        IDL> restore,'/home/vieques2/galaxy/grids/1436+05/gridbf_1436+05a.sav'
;        IDL> restore,'img.sav'
;        IDL> restore,'contour.sav' 
;        
;
;        REGIONS OF CODE THAT MAY NEED ADAPTATION:
;        Labels are created in lines 64 through 87. If you want a different
;        format adjust accordinly.
;
;        The size of the image may need adjusting in line 94.
;
;        Lines 101 through 114 explain inverting the image and placement of the
;        image. These lines will need adjusting so experiment with them until
;        something works for your image.
;
;        The size and location of the beam will need to be adjusted for your
;        particular plot. Adjust accordinly in line 121. The beam size is 
;        4 arcminutes.
;
;        The position of the plot may need to be adjusted so labels can be read.
;        Adjust accordinly in line 126.
;
;REVISION HISTORY:
;	Created by Sabrina Stierwalt
;	Revised and Documented July 2009, Tess Senty
;
;-

PRO OVERLAY,grid,znew,rahr,decdeg,c_levels,xmin,xmax,ymin,ymax,img,channel_start,channel_end,velocity_start,velocity_end

;this is about as big as you can make the window and still be able to see the 
;whole thing on your screen
window,/free ,retain=2,xsize=900,ysize=900 
erase,color=255 ;makes the background white

;in case you are repeatedly running through these lines individually, these next
;2 lines only need to be done the first time to set up the window appropriately:
contour, znew, rahr,decdeg, xstyle=1, ystyle=1,xrange=[xmax,xmin],yrange=[ymin,ymax],levels=c_levels,xtitle='!6 Right Ascension (J2000)',ytitle='Declination (J2000)', $
background=255,color=1,/nodata,charsize=1.5,xtick_get=xaxislabel, ytick_get=yaxislabel
erase,color=255

;Creating RA labels in the form: "00h00m00s"
nlabels=n_elements(xaxislabel)
for i=0, nlabels-1 do if (xaxislabel[i] lt 0) then xaxislabel[i]=xaxislabel[i]+24

rahour=floor(xaxislabel)
raminute=floor((xaxislabel-rahour)*60)
rasecond=round(((xaxislabel-rahour)*60-raminute)*60)
xlabels=strarr(nlabels)

for i=0, nlabels-1 do xlabels[i]=string(rahour[i],format='(i2)')+'h'+string(raminute[i],format='(i2)')+'m'+string(rasecond[i],format='(i2)')+'s'

print, xlabels

;Creating DEC labels in the form: 00d00m00s
nlabels=n_elements(yaxislabel)
decdegree=floor(yaxislabel)
decminute=floor((yaxislabel-decdegree)*60)
decsecond=round(((yaxislabel-decdegree)*60-decminute)*60)

ylabels=strarr(nlabels)

for i=0, nlabels-1 do ylabels[i]=string(decdegree[i],format='(i2)')+'d'+string(decminute[i],format='(i2)')+'m'+string(decsecond[i],format='(i2)')+'s'

print, ylabels

;gather data on the plot size so that we know how big to make the image
PX = !X.WINDOW * !D.X_VSIZE  
PY = !Y.WINDOW * !D.Y_VSIZE 

;you can change the size of the image
imgresizedimg=congrid(img,600,600) 
print, 'Before invert:',min(imgresizedimg), max(imgresizedimg)
SZ = SIZE(imgresizedimg)
imgresizedimg=(-1.)*imgresizedimg ;invert!
print, 'After invert:',min(imgresizedimg), max(imgresizedimg)
loadct,0

;You may need to adjust the position of the image. Add or subtract to PX[0] and
;PY[0] until the image is in the correct spot. 
;Also, if you end up with an all black or all white image you will need to 
;adjust either the number you are using or the entire sign of the number: 
;"imgresizeimg >(-980)" or "imgresizeimg <(980)"
;note if you are plotting white on black the following line will look more like:
;tvscl,imgresizedimg < 980, PX[0], PY[0]
;To decide on what number to use, look at min(imgresizedimg) and pick a number 
;slightly larger than min(abs(imgresizedimg)). For example, I decided on:
;tvscl,imgresizedimg>(-980),PX[0],PY[0]
;while before inverting the image, min(imgresizedimg)=920
;Adjust below accordingly:

tvscl,imgresizedimg>(-1000),PX[0]+60,PY[0]+60

;Plotting the beam size:
phi=findgen(32)*(!PI*2/32.)
usersym,cos(phi),sin(phi),/fill
;You will need to adjust the size of the beam (using symsize) and the coordinate
;locations to match your particular plots. 
;oplot,[0,xmax-0.005],[0,ymin+0.04],psym=8,symsize=4,color=1
;xyouts,0.2,0.2,'Beam',color=1,charsize=1.7, /normal

;Plot: the position of the plot may need to be moved to match the image.
;for example:
position=[PX[0]+60,PY[0]+60,PX[0]+SZ[1]+60,PY[0]+SZ[2]+60]
contour, znew, rahr,decdeg, xstyle=1, ystyle=1,thick=0.5,levels=c_levels,position=position,xrange=[xmax,xmin],yrange=[ymin,ymax],xtickname=xlabels,c_linestyle=0, $
ytickname=ylabels, xtitle='!6 Right Ascension (hour)',ytitle='Declination (degree)',title='HI contour SDSSr overlay (0.38 deg)',background=255,color=1,/noerase,/device,charsize=1.5

;display channel range label on plot
xyouts, 0.10, 0.95, "channels:", charsize=1.5, charthick=1,color=1, /normal
xyouts, 0.16, 0.95, channel_start, charsize=1.2, charthick=1,color=1, /normal
xyouts, 0.22, 0.95, "-", charsize=1.2, charthick=1,color=1, /normal
xyouts, 0.20, 0.95, channel_end, charsize=1.2, charthick=1,color=1, /normal

;display velocity range label on plot
xyouts, 0.10, 0.93, "velocities:", charsize=1.5, charthick=1,color=1, /normal
xyouts, 0.14, 0.93, velocity_start, charsize=1.2, charthick=1,color=1, /normal
xyouts, 0.23, 0.93, "-", charsize=1.2, charthick=1,color=1, /normal
xyouts, 0.19, 0.93, velocity_end, charsize=1.2, charthick=1,color=1, /normal

END
