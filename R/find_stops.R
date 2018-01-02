library(sp)

#egtrack = globalized_tracks[[3]]

length_egtrack = dim(egtrack)[1]
bool_stop = vector(length = length_egtrack-1)
dist_window_m = 0.5
#Temporal window = 1.5 seconds
i = 2
while(i < length_egtrack-1)
{
  sum_dist = egtrack@connections$distance[[i-1]] + egtrack@connections$distance[[i]] + egtrack@connections$distance[[i+1]]
  if(sum_dist <= dist_window_m)
  {
    bool_stop[i] = TRUE
  }
  i = i+1
}

egtrack_coords = coordinates(egtrack)[1:dim(egtrack)-1,]
bpds = as.data.frame(cbind(egtrack_coords, bool_stop))

find_diffs_it = function(xyb)
{
  flag = TRUE
  breaklist = c()
  x = 1
  dimx = dim(xyb)[1]
  while(x < dimx)
  {
    z = 1
    while(xyb[x,3] == xyb[x+1,3] && x < dimx)
    {
      x = x+1
      if(x >= dimx)
      {
        flag = FALSE
      }
    }
    breaklist = append(breaklist, x)
    if(!flag) break
    x = x+1
    if(x >= dimx) flag = FALSE
    while(x+1 <= dimx && xyb[x,3] == xyb[x+1,3])
    {
      x = x+1
      if(x >= dimx)
      {
        flag = FALSE
      }
    }
    if(flag)
    {
      x = x+1
      breaklist = append(breaklist, x)
    } else {
      breaklist = append(breaklist, dimx)
    }
  }
  return(breaklist[1:length(breaklist)-1])
}

bpts = find_diffs_it(bpds)
no_of_stop = length(bpts)/2
bpts_mat = matrix(data = bpts, ncol = 2, byrow = TRUE, dimnames = list(c(), c("start", "end")))
bpts_df = as.data.frame(bpts_mat)
duration = vector(length = dim(bpts_df)[1])
bbox = list()
##plot(egtrack, type = 'b')
for(i in 1:dim(bpts_df)[1])
{
  duration[i] = difftime(egtrack@endTime[bpts_df$end[i]], egtrack@endTime[bpts_df$start[i]], units = "secs")
  bbox[[i]] = bbox(coordinates(egtrack)[bpts_df$start[i]:bpts_df$end[i],])
  #rect(xleft = bbox[[i]][1,1], ybottom = bbox[[i]][2,1], xright = bbox[[i]][1,2], ytop = bbox[[i]][2,2], col = rgb(1,0,0,0.1), border = TRUE, lwd = 2)
}
#bbox
bpts_df = cbind(bpts_df, as.data.frame(duration))
