PRO SLICE_IT_TEST, datacube, channel_center, channel_boxcar, channel_increment, level_scale, pos_x, pos_y, pos_size, postscrypt
;this code is work in progress.  Feel free to make suggestions.
;written by Tom Balonek, Colgate University, current version 2007 May 08
;to call this procedure, 
; be sure to first:     restore,'gridbf_1234+06a.sav'
; then:     slice_it_test,grid,765,1,1,1.0,10,60,50,0
;  or       slice_it_test,grid,260,1,1,0.7,49,55,19,0

; pos_x and pos_y are lower right corner of zoomed plot (minimum x and y)
;   pos_size is size of zoomed in plot
; postscri(y)pt option not yet implemented.  Use gimp / grab to make copy   

;this program makes contour plots for specified channels in a grid datacube


;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
; create and set parameters for a new window for graphs
;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=

;set background color to white/ plot color to black
!p.background=255
!p.color=0

;activate indexed color model using device
device,decomposed=0
loadct,0

;introduce window size variables 
window_xsize = 900
window_ysize = 900
window_size_ratio = float(window_ysize) / float(window_xsize)

;if postscript parameter is not set to 1, window output is directly displayed to user
if (postscrypt ne 1) then begin
;display blank window sized to set parameters
window,/free,xsize=window_xsize,ysize=window_ysize
window_index = !d.window
print,'window_index: ', window_index
endif

plot_size = 0.18
inbox_label_size = 1.3
inbox_label_thick = 2

;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
; get ratio of character width/height to window width/height
;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
window_character_xsize = float(!d.x_vsize)
window_character_ysize = float(!d.y_vsize)

;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
; set up page format for postscript output
;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=

page_width = 8.5
page_height = 11.0
page_xsize = 7.5
page_ysize = 7.5
page_xoffset = (page_width - page_xsize) * 0.5
page_yoffset = (page_height - page_ysize) * 0.5

;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
; set up right ascension & declination and redshift indices for the datacube size
;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=

;when program is called, the datacube parameter is passed the grid structure
;the items nx, ny, nz are long/integer variables within the grid structure -
;they are accessed and stored to size variables
size_x = datacube.nx
size_y = datacube.ny
size_z = datacube.nz

data_xrange = [size_x,0]
data_yrange  =[0,size_y]

xrange = [size_x,0]
yrange  =[0,size_y]

;create index arrays of size nx, ny, nz accessed from the grid structure
x=findgen(size_x)
y=findgen(size_y)
z=findgen(size_z)

;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
; set up window if zooming in on an area; check if plotting beyond data range
;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=

if (pos_size ne 0) then begin
xrange = [pos_x + pos_size - 1, pos_x]
yrange = [pos_y, pos_y + pos_size - 1]
if ( ((pos_x + pos_size -1) gt size_x)) or ((pos_y + pos_size -1) gt size_y) then begin
   print, ' WARNING! Plot region extends beyond data range.'
   print, 'plot_x_range = ', xrange, 'plot_y_range = ', yrange, $
          format='(2(4x, a15, 2i6))'
   print, 'data_x_range = ', data_xrange, 'data_y_range = ', data_yrange, $
          format='(2(4x, a15, 2i6))'

endif
endif

;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
; open postscript device
;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=

if (postscrypt eq 1) then begin
entry_device = !d.name
set_plot, 'PS'
device,/portrait
device, filename='slice_it_plot.ps'
device, xsize=page_xsize, ysize=page_ysize, xoffset=page_xoffset, yoffset=page_yoffset, /inches
; set postscript character size
postscript_character_xsize = round(window_xsize / page_xsize)
postscript_character_ysize = round(window_ysize / page_ysize)
device, set_character_size = [postscript_character_xsize, postscript_character_xsize]
endif

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

nrows = 4
ncols = 4
center_plot_index = floor ((nrows * ncols) / 2) + 1

for irow = 1, nrows do begin
for icol = 1, ncols do begin

plot_index = (irow - 1) * ncols + icol

channel_offset= (plot_index - center_plot_index) * channel_increment
channel = channel_center + (channel_offset)
velocity=datacube.velarr(channel)

arr = (datacube.d[channel,0,x,y] + datacube.d[channel,1,x,y]) / 2.0
;note arr has dimensions [1,1,size_x,size_y]

if (channel_boxcar ne 1) then begin
   channel_boxcar_min = fix(channel - floor((channel_boxcar - 1) / 2.0))
   channel_boxcar_max = fix(channel +  ceil((channel_boxcar - 1) / 2.0))
   arr = arr * 0.0
   for chann = channel_boxcar_min, channel_boxcar_max do begin
      arr = arr + (((datacube.d[chann,0,x,y] + datacube.d[chann,1,x,y]) / 2.0) $
                   / float(channel_boxcar))
   endfor
endif

x1 = 0.05 + plot_size * (icol - 1)
y1 = 0.05 + plot_size * (nrows - irow)
x2 = x1 + plot_size
y2 = y1 + plot_size 

if ((irow eq nrows) and (icol eq 1)) then begin

;this plots 4X4 grid
contour, arr[0,0,x,y], levels=levels, xrange=xrange, yrange=yrange, xstyle=1, ystyle=1, position=[x1,y1,x2,y2],  /noerase

endif else begin

;this plots 4X4 grid
contour, arr[0,0,x,y], levels=levels, xrange=xrange, yrange=yrange, xstyle=1, ystyle=1, position=[x1,y1,x2,y2], xtickformat='(" ",A1)', ytickformat='(" ",A1)', /noerase

endelse

;label_channel = string(round(velocity),format='(i4)')
label_channel = string(channel,format='(i4)')
label_pos_x = x1 + 0.75 * plot_size 
label_pos_y = y1 + 0.005
xyouts, label_pos_x, label_pos_y, label_channel, charsize=inbox_label_size, charthick=inbox_label_thick, /normal

endfor
endfor

;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
; list some parameters at bottom of page
;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=

contour_levels_text = string ('contour levels:',levels, format='(a15,10f6.1)')

xyouts, 0.055, 0.01, 'boxcar:', /normal
xyouts, 0.057, 0.01, channel_boxcar, /normal
xyouts, 0.15, 0.01, contour_levels_text, /normal
xyouts, 0.60, 0.01, datacube.name, /normal
xyouts, 0.70, 0.01, 'slice_it', /normal
date=systime()
xyouts, 0.80, 0.01, date, /normal

;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
; close postscript device
;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=

if (postscrypt eq 1) then begin
device, /close_file
set_plot, entry_device
endif

;=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=

END
