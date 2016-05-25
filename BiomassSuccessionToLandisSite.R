
#############
#############
####  BiomassSuccesion inputs (v3.1) to LANDIS-II Site (v)
####  Dominic Cyr
#############
#############

rm(list=ls())

setwd("~/Travail/SCF/Landis/LandisGrowthCalib")
LandisInputsDir <- "~/Dropbox/LANDIS-II_IA_SCF/LandisInputs"

wwd <- paste(getwd(), Sys.Date(), sep="/")
dir.create(wwd)
setwd(wwd)
rm(wwd)

### area
a <- "AM"


### 'vegCodes' is the species master list
### It indicates which species to look in picus output folders
### 'ecoNames' gives the ecozones full names
require(RCurl)
readURL <- "https://raw.githubusercontent.com/dcyr/LANDIS-II_IA_generalUseFiles/master/"
vegCodes <- read.csv(text = getURL(paste(readURL, "vegCodes.csv", sep="/")))
ecoNames <- read.csv(text = getURL(paste(readURL, "ecoNames.csv", sep="/")))
species <- read.table(text = getURL(paste0(readURL, "LandisInputs/", a, "/species_", a, ".txt")),
                       skip=1, blank.lines.skip=T, comment.char=">")
colnames(species) <- c("Species", "longevity", "SexualMaturity", "ShadeTol", "FireTol", "EffSeedDispersal", "MaxSeedDispersal", "VegReprodProb", "SproutMinAge", "SproutMaxAge", "PostFireRegen")
###########
####
spp <- species$Species
rownames(species) <- spp
species <- species[,-1]

######## necessary for R to print large numbers without the scientific notation
options("scipen"=5)
###

###########
#### fetching some parameters in 'biomass-succession-main-inputs'
MainInputs <- scan(paste0(LandisInputsDir, "/", a, "/biomass-succession-main-inputs_", a, "_Baseline.txt"), what="character", sep=NULL)
LeafLongevity <- WoodyDecayRate <- MortalityShape <- GrowthCurve <- numeric()
for (sp in spp) { # sp <-spp[1]
	LeafLongevity <- append(LeafLongevity, as.numeric(MainInputs[which(MainInputs==sp)+1]))
	WoodyDecayRate <- append(WoodyDecayRate, as.numeric(MainInputs[which(MainInputs==sp)+2]))
	MortalityShape <- append(MortalityShape, as.numeric(MainInputs[which(MainInputs==sp)+3]))
	GrowthCurve <- append(GrowthCurve, as.numeric(MainInputs[which(MainInputs==sp)+4]))
}

###########
#### fetching dynamic inputs (baseline only)
DynamicInputs <- read.table(paste0(LandisInputsDir, "/", a, "/biomass-succession-dynamic-inputs_", a, "_Baseline.txt"), skip=1, blank.lines.skip=T, comment.char=">")
colnames(DynamicInputs) <- c("year", "ecoregion", "species", "probEst", "MaxANPP", "MaxB")
###########


###########
#### Printing sp- and landtype-specific parameters to landis-site input file. 
for (y in unique(DynamicInputs$year))	{#  y<-0
	for (e in unique(DynamicInputs$ecoregion))	{ #e <- "tmp_XM"
		for (sp in spp)	{   ### sp <- "BETUPOPU"
      sppIndex <- which(rownames(species)==sp)
			DynIndex <- intersect(which(DynamicInputs$ecoregion==e),
                            intersect(which(DynamicInputs$species==sp),
                            which(DynamicInputs$year==y)))
			sink(paste0(sp, "_", e, "_", y, ".txt"))
				cat(paste(unlist(c(sp, species[sppIndex, c("longevity","ShadeTol", "SexualMaturity")], LeafLongevity[sppIndex], WoodyDecayRate[sppIndex],
					species[sppIndex, c("VegReprodProb", "SproutMinAge", "SproutMaxAge")],
					DynamicInputs[DynIndex, c("MaxANPP", "MaxB")],
					MortalityShape[sppIndex],
					GrowthCurve[sppIndex],
					c(NA, NA),
					DynamicInputs[DynIndex,"probEst"]), use.names=FALSE), "\n", sep=""), sep="")
			sink()

		}
	}
}
####




