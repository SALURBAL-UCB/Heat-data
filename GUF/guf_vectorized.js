//Author: Irene Farah (irenef@berkeley.edu)
//Create sum of GUF by 9km x 9km pixels (at the ERA5Land resolution) using Google Earth Engine
//Read in GUF files (first import them into the code (find in data folder))
var pan_guf1=ee.Image(guf1);
var pan_guf2=ee.Image(guf2);
var pan_guf3=ee.Image(guf3);
var p1=ee.Image(per1);
var p2=ee.Image(per2);
var p3=ee.Image(per3);
var p4=ee.Image(per4);
var p5=ee.Image(per5);
var p6=ee.Image(per6);
var p7=ee.Image(per7);
var p8=ee.Image(per8);
var p9=ee.Image(per9);
var p10=ee.Image(per10);
var p11=ee.Image(per11);
var p12=ee.Image(per12);
var p13=ee.Image(per13);
var p14=ee.Image(per14);
var p15=ee.Image(per15);
var p16=ee.Image(per16);
var p17=ee.Image(per17);
var p18=ee.Image(per18);
var p19=ee.Image(per19);
var p20=ee.Image(per20);
var p21=ee.Image(per21);
var p22=ee.Image(per22);
var p23=ee.Image(per23);

//Merge GUF files together
var collection=ee.ImageCollection([pan_guf1,pan_guf2,pan_guf3
	,p1, p2, p3, p4, p5, p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,
	p16,p17,p18,p19,p20,p21,p22,p23]);

var pop2010=collection.mode();

//var ok=ee.ImageCollection(guf);
//var pop2010 = ok.mosaic();
                      
//Read 9kmx 9km pixels created from temperature data (find in data)
var fc = ee.FeatureCollection(vectorized);

// Clip to the output image
var clipped = pop2010.clipToCollection(fc);

//Sum GUF by 9km x 9km piels
var maineMeansFeatures = clipped.reduceRegions({
  collection: fc,
  reducer: ee.Reducer.sum(),
  scale: 100,
});

//To visualize results:
var viz = {min:0.0, max:20, palette:"F3FEEE,00ff04,075e09,0000FF,FDFF92,FF2700,FF00E7"};                     
Map.addLayer(maineMeansFeatures,viz)

// Export the FeatureCollection to a shapefile: guf_panperu_vectorized_complete.shp in wp_guf_vectorized zipfile
Export.table.toDrive({
  collection: maineMeansFeatures,
  description:'guf_panperu_vectorized',
  fileFormat: 'KML'
});
