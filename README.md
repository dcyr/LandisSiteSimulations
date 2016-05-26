# LANDIS-II Biomass Succession pixel-level simulations
Dominic Cyr  
Updated on May 26 2016

-------


In this repository you can find some scripts and information about how we tuned and verified the pixel-level successionnal patterns that emerged from [_LANDIS-II Biomass Succession_][1].

While some of the most important parameters were derived from stand-level model PICUS ([more information here][2]), some of the parameters were set through a more subjective process that we want to make as transparent as possible by sharing it here. However, the procedure remains subjective and imperfect, and we encourage anyone who has questions, comments, or suggestions, to contact us so that we can see how it can be improved.

### Repo Content  
  
#### Vignettes
  
Some of the results of our fine tuning / validation process.

* Atlantic Maritimes  
  
    + Northern New Brunswick - Mesic station  
  
    + Southern New Brunswick - Mesic station  
  
* Boreal Shield  
  
    + [Boreal Softwood - Mesic station][7]
    
    + [Boreal Mixedwood - Mesic station][8]
    
    + [Temperate Hardwood - Mesic station][9]
  
* Boreal Plains  
  
#### Scripts
  
* [BiomassSuccessionToLandisSite.R][3]  - An R script that takes Landis-II Biomass Succession input files and translate them into a format that can be directly imported using Landis-Site graphical interface.
  
* [MultiSppLandisSiteViz.R][4]  - An R script to visualize multi-spp, multiple remplicate, pixel level simulations produced by Landis-Site.
  
  
[1]: http://www.landis-ii.org/extensions/biomass-succession
[2]: http://github.com/dcyr/PicusToLandisIIBiomassSuccession
[3]: https://github.com/dcyr/LandisSiteSimulations/blob/master/BiomassSuccessionToLandisSite.R
[4]: https://github.com/dcyr/LandisSiteSimulations/blob/master/MultiSppLandisSiteViz.R

[7]: https://github.com/dcyr/LandisSiteSimulations/blob/master/Vignettes/landisSiteVignette_BSE_4144.md
[8]: https://github.com/dcyr/LandisSiteSimulations/blob/master/Vignettes/landisSiteVignette_BSE_4223.md
[9]: https://github.com/dcyr/LandisSiteSimulations/blob/master/Vignettes/landisSiteVignette_BSE_4233.md

