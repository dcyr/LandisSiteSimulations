# LANDIS-II Biomass Succession pixel-level simulations
Dominic Cyr  
Updated on May 31 2016

-------

### Introduction

In this repository you can find some scripts and information about how we tuned and verified the pixel-level successionnal patterns that emerged from [_LANDIS-II Biomass Succession_][1].

While some of the most important parameters were derived from stand-level model PICUS ([more information here][2]), some of the parameters were set through a more subjective process that we want to make as transparent as possible by sharing it here. However, the procedure remains subjective and imperfect, and we encourage anyone who has questions, comments, or suggestions, to contact us so that we can see how it can be improved.


### LANDIS-site vignettes
  
Some of the results of our fine tuning / validation process.

* Atlantic Maritimes  
  
    + [Northern New Brunswick - Mesic station][5]
  
    + [Southern New Brunswick - Mesic station][6]
  
* Boreal Shield  
  
    + [Boreal Softwood - Mesic station][7]
    
    + [Temperate Mixedwood - Mesic station][8]
    
    + [Temperate Hardwood - Mesic station][9]
  
* Boreal Plains  
    + [Boreal Plains - Lowland][10]
    
    + [Boreal Plains - Upland][11]
    
  
  
### Scripts
  
* [BiomassSuccessionToLandisSite.R][3]  - An R script that takes Landis-II Biomass Succession input files and translate them into a format that can be directly imported using Landis-Site graphical interface.
  
* [MultiSppLandisSiteViz.R][4]  - An R script to visualize multi-spp, multiple remplicate, pixel level simulations produced by Landis-Site.
  
  
[1]: http://www.landis-ii.org/extensions/biomass-succession
[2]: http://github.com/dcyr/PicusToLandisIIBiomassSuccession
[3]: https://github.com/dcyr/LandisSiteSimulations/blob/master/BiomassSuccessionToLandisSite.R
[4]: https://github.com/dcyr/LandisSiteSimulations/blob/master/MultiSppLandisSiteViz.R
[5]: https://github.com/dcyr/LandisSiteSimulations/blob/master/Vignettes/landisSiteVignette_AM_4913.md
[6]: https://github.com/dcyr/LandisSiteSimulations/blob/master/Vignettes/landisSiteVignette_AM_5052.md
[7]: https://github.com/dcyr/LandisSiteSimulations/blob/master/Vignettes/landisSiteVignette_BSE_4144.md
[8]: https://github.com/dcyr/LandisSiteSimulations/blob/master/Vignettes/landisSiteVignette_BSE_4223.md
[9]: https://github.com/dcyr/LandisSiteSimulations/blob/master/Vignettes/landisSiteVignette_BSE_4233.md
[10]: https://github.com/dcyr/LandisSiteSimulations/blob/master/Vignettes/landisSiteVignette_BP_6441.md
[11]: https://github.com/dcyr/LandisSiteSimulations/blob/master/Vignettes/landisSiteVignette_BP_6603.md

