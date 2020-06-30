//Author: Irene Farah (irenef@berkeley.edu)
//Create sum of WorldPop (year=2010) by 9km x 9km pixels (at the ERA5Land resolution)
// Aggregating WorldPop 100m x 100m data to 9km x 9km cells for Latin America

var WP_2010  = worldPop
  //.filter(ee.Filter.inList('country', ['GTM']))
  .filter(ee.Filter.equals('UNadj', 'no'))
  .filter(ee.Filter.equals('year', 2010))
  .select('population');


var pop2010 = WP_2010.mosaic()
                      .select('population')
                      .rename('pop2010')
                      .set('system:time_start',ee.Date.fromYMD(2010,1,1)); 
                      
//Read in 9km x 9km vector created from temperature data (ERA5Land resolution)
var fc = ee.FeatureCollection(vectorized);

// Clip to the output image to the AD boundaries.
var clipped = pop2010.clipToCollection(fc);

var maineMeansFeatures = clipped.reduceRegions({
  collection: fc,
  reducer: ee.Reducer.sum(),
  scale: 100,
});

print(ee.Feature(maineMeansFeatures.first()).select(pop2010.bandNames()));

//To visualize results:
var viz = {min:0.0, max:20, palette:"F3FEEE,00ff04,075e09,0000FF,FDFF92,FF2700,FF00E7"};                  
Map.addLayer(maineMeansFeatures,viz)

// Export the FeatureCollection to a shapefile: worldpoppers_bueno_convec.shp
Export.table.toDrive({
  collection: maineMeansFeatures,
  description:'worldpop_shp',
  fileFormat: 'KML'
});