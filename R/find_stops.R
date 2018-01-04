library(sp)

#egtrack = globalized_tracks[[5]]

stop = c(0)
nop = c(0)
perc = c(0)
dur = c(0)


mov_pat = data.frame(stop,nop,perc,dur)



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

times = as.POSIXct(egtrack@sp$time[1:dim(egtrack)[1]-1])


bpds = as.data.frame(cbind(egtrack_coords, bool_stop,times))



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


stop_it = function(xyb)
{
  
  #mov_pat = rbind(mov_pat, c(4,4,4))
  #mov_pat[2,1] = 2
  #bpds[1,3] = 1
  #xyb = bpds
  
  dimx = dim(xyb)[1]
  x = 0
  k = 2
  
  while(x< dimx){
    x=x+1
    cur = xyb[x,3]
    
    if(x==1) {
      mov_pat = rbind(mov_pat,c(cur,1,10,xyb[x,4])) 
      next
    }
    
    prev = xyb[x-1,3]
    
    if(cur != prev){
      t1 = mov_pat[k,4]
      t2 = xyb[x,4]
      res = difftime(as.POSIXct(t2,origin="1970-01-01"), as.POSIXct(t1,origin="1970-01-01"), units = "secs")
      mov_pat[k,4] = res
      k=k+1
      mov_pat = rbind(mov_pat,c(cur,0,10,xyb[x,4]))
    }
      
    mov_pat[k,2] = mov_pat[k,2] + 1
    
    if(x==dimx-1) {
      t1 = mov_pat[k,4]
      t2 = xyb[x,4]
      res = difftime(as.POSIXct(t2,origin="1970-01-01"), as.POSIXct(t1,origin="1970-01-01"), units = "secs")
      mov_pat[k,4] = res
    }
  }
  mov_pat = data.frame(mov_pat[2:dim(mov_pat)[1],])

  percentage = 100/sum(mov_pat$dur)
  perc = mov_pat$dur * percentage
  mov_pat = cbind(mov_pat,"percentage"=perc)
  
  
  return(mov_pat)
}

mov_pat = stop_it(bpds)

bpts = find_diffs_it(bpds)


no_of_stop = length(bpts)/2
bpts_mat = matrix(data = bpts, ncol = 2, byrow = TRUE, dimnames = list(c(), c("start", "end")))
bpts_df = as.data.frame(bpts_mat)
duration = vector(length = dim(bpts_df)[1])
bbox = list()
##plot(egtrack, type = 'b')
for(i in 1:dim(bpts_df)[1])
{
  #duration[i] = difftime(egtrack@endTime[bpts_df$end[i]], egtrack@endTime[bpts_df$start[i]], units = "secs")
  #bbox[[i]] = bbox(coordinates(egtrack)[bpts_df$start[i]:bpts_df$end[i],])
  #rect(xleft = bbox[[i]][1,1], ybottom = bbox[[i]][2,1], xright = bbox[[i]][1,2], ytop = bbox[[i]][2,2], col = rgb(1,0,0,0.1), border = TRUE, lwd = 2)
}
#bbox
#bpts_df = cbind(bpts_df, as.data.frame(duration))
