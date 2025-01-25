This README file was generated on 2025-01-25 by Maria Fernanda Valle Seijo.
------------------------------------------------------------------------------------------------------------------------------------
GENERAL INFORMATION

Title of Dataset: MCD19A2 v061 MODIS/Terra+Aqua Land Aerosol Optical Depth Daily L2G Global 1 km SIN Grid

- Author/Principal Investigator Information:
- Name: Alexei Lyapustin
- ORCID: 0000-0003-1105-5739
- Institution: NASA Goddard Space Flight Center, Greenbelt, Maryland
- Email: Alexei.I.Lyapustin@nasa.gov

Point of Contact:
- Yujie Wang 
- yujie.wang@nasa.gov

Date of data collection: 14/10/2024 - 21/10/2024
Information about geographic location of data collection: h12.v12, h12v11, h13v11, h12v12 (tiles used for this project)

------------------------------------------------------------------------------------------------------------------------------------
DATA & FILE OVERVIEW

MAIAC is a new advanced algorithm which uses time series analysis and a combination of pixel- and image-based processing to improve accuracy of cloud detection, aerosol  retrievals and atmospheric correction. Consistently with the entire C6 MODIS land processing, the top-of-atmosphere (TOA) L1B reflectance includes standard C6 calibration  augmented with polarization correction for MODIS Terra, residual de-trending and MODIS Terra-to-Aqua cross-calibration (Lyapustin, A., Y. Wang, X. Xiong, G. Meister, S.  Platnick, R. Levy, B. Franz, S. Korkin, T. Hilker, J. Tucker, F. Hall, P. Sellers, A. Wu, A. Angal (2014), Science Impact of MODIS C5 Calibration Degradation and C6+  Improvements, Atmos. Meas. Tech., 7, 4353-4365, doi:10.5194/amt-7-4353-2014).

The L1B data are first gridded into 1km MODIS sinusoid grid using area-weighted method. Due to cross-calibration, MAIAC processes MODIS Terra and Aqua jointly as a single  sensor.

MAIAC provides a suite of atmospheric and surface products in three HDF-EOS 2.1.x files: daily MCD19A1 (spectral BRF, or surface reflectance), daily MCD19A2 (atmospheric  properties), and 8-day MCD19A3 (spectral BRDF/albedo).

File List: 

- MCD19A2_061_2017: MCD19A2 V061 daily hdf file for each tile (h12.v12, h12v11, h13v11, h12v12) for year 2017.
--- Date that the files were created: 113 to 114 (julian date) of 2023.
- MCD19A2_061_2018: MCD19A2 V061 daily hdf file for each tile (h12.v12, h12v11, h13v11, h12v12) for year 2018.
--- Date that the files were created: 114 to 122 (julian date) of 2023.
- MCD19A2_061_2019: MCD19A2 V061 daily hdf file for each tile (h12.v12, h12v11, h13v11, h12v12) for year 2019.
--- Date that the files were created: 123 to 132 (julian date) of 2023.
- MCD19A2_061_2020: MCD19A2 V061 daily hdf file for each tile (h12.v12, h12v11, h13v11, h12v12) for year 2020.
--- Date that the files were created: 132 to 142 (julian date) of 2023.
- MCD19A2_061_2021: MCD19A2 V061 daily hdf file for each tile (h12.v12, h12v11, h13v11, h12v12) for year 2021.
--- Date that the files were created: 142 to 157 (julian date) of 2023.
- MCD19A2_061_2022: MCD19A2 V061 daily hdf file for each tile (h12.v12, h12v11, h13v11, h12v12) for year 2021.
--- Date that the files were created: 225 to 232 (julian date) of 2024.
  

------------------------------------------------------------------------------------------------------------------------------------
SHARING/ACCESS INFORMATION

Licenses/restrictions placed on the data: 
- Data Access: All data products distributed by NASA's Land Processes Distributed Active Archive Center (LP DAAC) are available at no charge.
- Data Redistribution: All LP DAAC current data and products acquired through the LP DAAC have no restrictions on reuse, sale, or redistribution.

Links to publicly accessible locations of the data: https://lpdaac.usgs.gov/products/mcd19a2v061/

Recommended citation for this dataset:
Lyapustin, A., Wang, Y. (2022). <i>MODIS/Terra+Aqua Land Aerosol Optical Depth Daily L2G Global 1km SIN Grid V061</i> [Data set]. NASA EOSDIS Land Processes Distributed Active Archive Center. Accessed 2025-01-25 from https://doi.org/10.5067/MODIS/MCD19A2.061

------------------------------------------------------------------------------------------------------------------------------------
METHODOLOGICAL INFORMATION


Description of methods used for collection/generation of data:
- Lyapustin, A., Wang, Y., Korkin, S., & Huang, D. (2018a). MODIS Collection 6 MAIAC algorithm. Atmospheric Measurement Techniques, 11(10), 5741–5765. https://doi.org/10.5194/amt-11-5741-2018
- Lyapustin, A., Wang, Y., Korkin, S., & Huang, D. (2018b). MODIS Collection 6 MAIAC algorithm. Atmospheric Measurement Techniques, 11(10), 5741–5765. https://doi.org/10.5194/amt-11-5741-2018
- Lyapustin, A., Wang, Y., Laszlo, I., Kahn, R., Korkin, S., Remer, L., Levy, R., & Reid, J. S. (2011). Multiangle implementation of atmospheric correction (MAIAC): 2. Aerosol algorithm. Journal of Geophysical Research, 116(D3), D03211. https://doi.org/10.1029/2010JD014986
- Lyapustin, A., Wang, Y., Laszlo, I., & Korkin, S. (2012). Improved cloud and snow screening in MAIAC aerosol retrievals using spectral and spatial analysis. Atmospheric Measurement Techniques, 5(4), 843–850. https://doi.org/10.5194/amt-5-843-2012
- Lyapustin, A., Wang, Y. (2022). MODIS/Terra+Aqua Land Aerosol Optical Depth Daily L2G Global 1km SIN Grid V061 [Data set]. NASA EOSDIS Land Processes Distributed Active Archive Center. Accessed 2025-01-24 from https://doi.org/10.5067/MODIS/MCD19A2.061

Description of methods used for data processing:
- Sub-dataset retrived: AOD at 470 nm 
- Mergeing: tile (h12.v12, h12v11, h13v11, h12v12) 
- Quality-Assurance procedures: The satellite-derived AOD were filtered using the Quality Assurance (QA) dataset, specifically applying QA Bits 8–11 set to "0000" to ensure "Best Quality" data.
- Reprojection: from SIN projection ("ESRI:53008") to WGS84 projection ("EPSG:4326")
- Crop: adjust the data to ROI of interest (-63.3870989919999985,-36.0441238820000009, -52.9739094979999976,-21.7195677349999983

------------------------------------------------------------------------------------------------------------------------------------
DATA-SPECIFIC INFORMATION 

Geographic Grid Projection Parameters:
-     Sinusoidal Projection
-     Projection            GCTP_SNSOID
-     ProjParam[0]          6371007.181
-     ProjParam[1 to 7]     0.0
-     ProjParam[8]          0.0
-     ProjParam[9]          0.0
-     ProjParam[10]         0.0
-     ProjParam[11 to 12]   0.0
-     Spherecode            -1
-     GridOrigin            HDFE_CENTER

dimensions:
-	Orbits:grid5km = variable (defined by global attribute Orbit_amount);
-	YDim:grid5km = 240 ;
-	XDim:grid5km = 240 ;
-	Orbits:grid1km = variable (defined by global attribute Orbit_amount);
-	YDim:grid1km = 1200 ;
-	XDim:grid1km = 1200 ;
 
variables:
-	short cosSZA(Orbits:grid5km, YDim:grid5km, XDim:grid5km) ;
-		cosSZA:long_name = "cosine of Solar Zenith Angle" ;
-		cosSZA:scale_factor = 0.0001 ;
-		cosSZA:add_offset = 0. ;
-		cosSZA:unit = "none" ;
-		cosSZA:_FillValue = -28672s ;
-		cosSZA:valid_range = 0s, 10000s ;
-	short cosVZA(Orbits:grid5km, YDim:grid5km, XDim:grid5km) ;
-		cosVZA:long_name = "cosine of View Zenith Angle" ;
-		cosVZA:scale_factor = 0.0001 ;
-		cosVZA:add_offset = 0. ;
-		cosVZA:unit = "none" ;
-		cosVZA:_FillValue = -28672s ;
-		cosVZA:valid_range = 0s, 10000s ;
-	short RelAZ(Orbits:grid5km, YDim:grid5km, XDim:grid5km) ;
-		RelAZ:long_name = "Relative Azimuth Angle" ;
-		RelAZ:scale_factor = 0.01 ;
-		RelAZ:add_offset = 0. ;
-		RelAZ:unit = "none" ;
-		RelAZ:_FillValue = -28672s ;
-		RelAZ:valid_range = -18000s, 18000s ;
-	short Scattering_Angle(Orbits:grid5km, YDim:grid5km, XDim:grid5km) ;
-		Scattering_Angle:long_name = "Scattering Angle" ;
-		Scattering_Angle:scale_factor = 0.01 ;
-		Scattering_Angle:add_offset = 0. ;
-		Scattering_Angle:unit = "none" ;
-		Scattering_Angle:_FillValue = -28672s ;
-		Scattering_Angle:valid_range = -18000s, 18000s ;
-	short Glint_Angle(Orbits:grid5km, YDim:grid5km, XDim:grid5km) ;
-		Glint_Angle:long_name = "Glint Angle" ;
-		Glint_Angle:scale_factor = 0.01 ;
-		Glint_Angle:add_offset = 0. ;
-		Glint_Angle:unit = "none" ;
-		Glint_Angle:_FillValue = -28672s ;
-		Glint_Angle:valid_range = -18000s, 18000s ;
-	short Optical_Depth_047(Orbits:grid1km, YDim:grid1km, XDim:grid1km) ;
-		Optical_Depth_047:long_name = "AOT at 0.47 micron" ;
-		Optical_Depth_047:scale_factor = 0.001 ;
-		Optical_Depth_047:add_offset = 0. ;
-		Optical_Depth_047:unit = "none" ;
-		Optical_Depth_047:_FillValue = -28672s ;
-		Optical_Depth_047:valid_range = -100s, 4000s ;
-	short Optical_Depth_055(Orbits:grid1km, YDim:grid1km, XDim:grid1km) ;
-		Optical_Depth_055:long_name = "AOT at 0.55 micron" ;
-		Optical_Depth_055:scale_factor = 0.001 ;
-		Optical_Depth_055:add_offset = 0. ;
-		Optical_Depth_055:unit = "none" ;
-		Optical_Depth_055:_FillValue = -28672s ;
-		Optical_Depth_055:valid_range = -100s, 4000s ;
-	short AOT_Uncertainty(Orbits:grid1km, YDim:grid1km, XDim:grid1km) ;
-		AOT_Uncertainty:long_name = "AOT uncertainty at 0.47 micron, range 0-4" ;
-		AOT_Uncertainty:scale_factor = 0.0001 ;
-		AOT_Uncertainty:add_offset = 0. ;
-		AOT_Uncertainty:unit = "mm" ;
-		AOT_Uncertainty:_FillValue = -28672s ;
-		AOT_Uncertainty:valid_range = 0s, 30000s ;
-	short FineModeFraction(Orbits:grid1km, YDim:grid1km, XDim:grid1km) ;
-		FineModeFraction:long_name = "Find mode fraction for Ocean" ;
-		FineModeFraction:scale_factor = 0.0001 ;
-		FineModeFraction:add_offset = 0. ;
-		FineModeFraction:unit = "none" ;
-		FineModeFraction:_FillValue = -28672s ;
-		FineModeFraction:valid_range = 0s, 10000s ;
-	short Column_WV(Orbits:grid1km, YDim:grid1km, XDim:grid1km) ;
-		Column_WV:long_name = "Column Water Vapor (in cm liquid water)" ;
-		Column_WV:scale_factor = 0.001 ;
-		Column_WV:add_offset = 0. ;
-		Column_WV:unit = "cm" ;
-		Column_WV:_FillValue = -28672s ;
-		Column_WV:valid_range = 0s, 30000s ;
-	short AOT_QA(Orbits:grid1km, YDim:grid1km, XDim:grid1km) ;
-		AOT_QA:long_name = "AOT_QA" ;
-		AOT_QA:unit = "none" ;
-		AOT_QA:data description = "Bits\tDefinition\n",
-    "0-2    Cloud Mask\n",
-    "       000 --- Undefined\n",
-    "       001 --- Clear\n",
-    "       010 --- Possible Cloudy\n",
-    "       011 --- Cloudy \n",
-    "       101 --- Cloud shadow\n",
-    "       110 --- Fire hotspot\n",
-    "       111 --- Water Sediments\n",
-    "3-4    Land Water Snow/ice  Mask\n",
-    "       00 --- Land\n",
-    "       01 --- Water\n",
-    "       10 --- Snow\n",
-    "       11 --- Ice\n",
-    "5-7  Adjacency Mask\n",
-    "       000 --- Normal condition\n",
-    "       001 --- Adjacent to cloud\n",
-    "       010 --- Surrounded by more than 8 cloudy pixels\n",
-    "       011 --- Single cloudy pixel\n",
-    "       100 --- Adjacent to snow\n",
-    "       101 --- Snow was previously detected for this pixel\n",
-    "8-11 QA AOT \n",
-    "       0000 --- Best quality \n",
-    "       0001 --- Water Sediments are detected\n",
-    "       0010 --- AC over water done, but AOT>0.5\n",
-    "       0011 --- There is 1 neighbor cloud\n",
-    "       0100 --- There is >1 neighbor clouds\n",
-    "       0101 --- no retrieval (cloudy, or whatever)\n",
-    "       0110 --- no retrievals near detected or previously snow\n",
-    "       0111 --- Climatology AOT: altituide above 3.5km(water), and 4.2km(land)\n",
-    "       1000 --- no retrieval due to sun glint\n",
-    "       1001 --- retrieved AOT is very low (<0.05) due to glint\n",
-    "       1010 --- AOT within +-2km from the coastline is replaced by nearby AOT\n",
-    "       1011 --- Land, Reserach Quality: AOT retrieved but CM is possibly cloudy\n",
-    "12    Glint mask\n",
-    "       0 --- glint is not detected\n",
-    "       1 --- glint is detected\n",
-    "13-14 Aerosol model\n",
-    "       00 --- background model\n",
-    "       01 --- Smoke model\n",
-    "       10 --- Dust model\n",
-    "15  Reserved",
-    "" ;
-		AOT_QA:_FillValue = 0s ;
-		AOT_QA:valid_range = 0s, 255s ;
-	byte AOT_MODEL(Orbits:grid1km, YDim:grid1km, XDim:grid1km) ;
-		AOT_MODEL:long_name = "AOT model used in retrieval" ;
-		AOT_MODEL:unit = "none" ;
-		AOT_MODEL:_FillValue = '\377' ;
-		AOT_MODEL:valid_range = '\0', '\12' ;
-	float Injection_Height(Orbits:grid1km, YDim:grid1km, XDim:grid1km) ;
-		Injection_Height:long_name = "Smoke Injection Height over local surface height, in km" ;
-		Injection_Height:unit = "meter" ;
-		Injection_Height:_FillValue = -99999.f ;
-		Injection_Height:valid_range = 0.f, 0.f ;
