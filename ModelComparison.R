### Convert to T/F. Threshold = 0.6
#pred_mapP2 <- pred_mapP
#pred_mapP2[pred_mapP2>=0.6]<-1
#pred_mapP2[pred_mapP2<0.6]<-0
#present_cells <- cellStats(pred_mapP2, 'sum')

#pred_mapF2 <- pred_mapF
#pred_mapF2[pred_mapF2>=0.6]<-1
#pred_mapF2[pred_mapF2<0.6]<-0
#future_cells <- cellStats(pred_mapF2, 'sum')

### Persistence
#persistence_map <- mask(pred_mapP2, pred_mapF2)
#persistent_cells <- cellStats(persistence_map, 'sum')
#persistence <- (persistent_cells*1.0/present_cells)

### Constraint
#constraint_map <- pred_mapF2-pred_mapP2
### to be continued...
