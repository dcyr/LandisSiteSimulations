rm(list=ls())

### user defined project directory (if necessary)
setwd("~/Travail/SCF/Landis/LandisGrowthCalib")
### user defined variables (could be used as argument for this script, slight modif needed,
### or, a loop could be built around it
a <- "BSE"
###
LandisSiteOutputDir <- paste0(getwd(), "/LANDIS-Site/outputs")


### setting working directory in the folder that is parent of the one of Landis Outputs
wwd <- paste(getwd(), Sys.Date(), sep="/")
dir.create(wwd)
setwd(wwd)
rm(wwd)

### 'vegCodes' is the species master list
### It indicates which species to look in picus output folders
### 'ecoNames' gives the ecozones full names
### Both files are maintained in another repo accessible on Github
require(RCurl)
readURL <- "https://raw.githubusercontent.com/dcyr/LANDIS-II_IA_generalUseFiles/master/"
vegCodes <- read.csv(text = getURL(paste(readURL, "vegCodes.csv", sep="/")))
ecoNames <- read.csv(text = getURL(paste(readURL, "ecoNames.csv", sep="/")))
######################
######################


multiSppOutputs <- paste(LandisSiteOutputDir, a, "multiSpp", sep="/")

landtypes <- list.dirs(multiSppOutputs, full.names = F)
landtypes <- landtypes[-1]

smoothingFun <- function(y, x) {
    model <- loess(y ~ x, span = 0.01)
    return(predict(model, x))
}

require(reshape2)
require(data.table)
require(dplyr)


############################################
############################################
#### Postprocessing and compiling Landis-Site outputs
sppOutputs <- standOutputs <- list()
descrip <- character()
i <- 1
############################################
############################################
for (l in landtypes) {
    folder <- paste(multiSppOutputs, l, sep="/")
    x <- list.files(folder)
    info <- x[grep("spp.txt", x)]
    x <- x[-grep(info, x)]
    info <- readLines(paste(folder, info, sep="/"))
    describ <- info[1]
    maxB <- as.numeric(info[(length(info)-1)])
    sppCode <- info[c(2:(length(info)-2))]
    sppName <- as.character(vegCodes[match(sppCode, vegCodes$LandisCode),"scientificShort"])

    for (r in seq_along(x)) {
        tmp <- read.csv(paste(folder, x[r], sep="/"))
        tmp[, "landtype"] <- l
        #outputs[[l]][[i]][, "sppCode"] <- sppCode
        tmp[, "describ"] <- describ
        tmp[, "replicate"] <- as.numeric(gsub("[^0-9]", "", x[r]))
        colnames(tmp)[grep("Biomass", colnames(tmp))] <- sppCode

        id.vars <- c("describ", "Year" , "landtype", "replicate")
        meas.vars1 <- sppCode

        ### smoothing
        smoothSpp <- apply(tmp[,sppCode], 2, function(y) smoothingFun(y=y, x=1:nrow(tmp)-1))
        smoothSpp[smoothSpp<0] <- 0
        tmp[,sppCode] <- smoothSpp

        meas.vars2 <-colnames(tmp)[grep("NumCohorts", colnames(tmp))]
        meas.vars.stand <- c("PctShade", "ShadeClass", "DeadWoodyBio")


        sppTmp1 <- melt(tmp[, c(id.vars, meas.vars1)],
                        id.vars = id.vars, meas.vars = meas.vars1,
                        value.name = "AGBiomass_gPerSqMeter",
                        variable.name = "species")

        sppTmp2 <- melt(tmp[, c(id.vars, meas.vars2)],
                        id.vars = id.vars, meas.vars = meas.vars2,
                        value.name = "numCohorts",
                        variable.name = "species")
        sppTmp2$species <- factor(sppCode[as.numeric(gsub("[^0-9]", "", sppTmp2$species))], levels = sppCode)

        sppTmp <- merge(sppTmp1, sppTmp2, by = c(id.vars, "species"))

        #head(sppTmp[-1], 100)
        sppTmp <-  arrange(sppTmp, Year, replicate, species)

        standTmp <- melt(tmp[, c(id.vars, meas.vars.stand)],
                         id.vars = id.vars, meas.vars = meas.vars.stand)

        sppOutputs[[i]] <- sppTmp
        standOutputs[[i]] <- standTmp
        i <- i+1
    }

}

sppOutputsLandisSites <- rbindlist(sppOutputs)
standOutputsLandisSites <- rbindlist(standOutputs)
### converting gPerSqMeter to tons per ha
sppOutputsLandisSites <- sppOutputsLandisSites%>%
    mutate(AGBiomass_tonsPerHa = AGBiomass_gPerSqMeter/100)


############################################
############################################
#### ggplot2 magic
require(ggplot2)
############################################
for (l in unique(sppOutputsLandisSites$landtype)){
    ###############
    ######## pixel composition - species biomass
    df <- sppOutputsLandisSites %>%
        filter(landtype == l) %>%
        mutate(simID = as.numeric(as.factor(paste(species, replicate))))

    df <- droplevels(df)
    title <- unique(df$describ)
    replicateN <- length(unique(df$replicate))
    spp <- levels(df$species)
    colors <- as.character(vegCodes[match(spp, vegCodes$LandisCode), "color"])

    shadeDf <- filter(standOutputsLandisSites, variable == "PctShade", landtype == l )
    shadeThresh <- c(0, 20, 40, 50, 70, 90)

    ### Absolute abundance
    linePlot <- ggplot(df, aes(x=Year, y=AGBiomass_tonsPerHa, colour=species)) +
        geom_line(size=0.3, alpha = 0.4,  group = df$simID) +
        stat_summary(fun.y="mean", geom="line", size = 0.5) +
        scale_colour_manual(values=colors) +
        guides(fill = guide_legend(reverse = TRUE)) +
        labs(title="Absolute abundance",
             y="Aboveground biomass\n(t/ha)\n",
             x="Year")
    ### Cumulative abundance
    stackPlot <- ggplot(df, aes(x = Year, y = AGBiomass_tonsPerHa, fill=species)) +
        stat_summary(fun.y="mean", geom="area", position = "stack",
                     color = "black", size = 0.3) +
        #geom_area(colour="black", size=0.2) +
        scale_fill_manual(values =colors) +
        guides(fill = guide_legend(reverse = TRUE)) +
        labs(title = "Cumulative abundance (average)",
             y = "Aboveground biomass\n(t/ha)\n",
             x = "Year")

    ### Proportions
    fillPlot <- ggplot(df, aes(x = Year, y=AGBiomass_tonsPerHa, fill=species)) +
        stat_summary(fun.y="mean", geom="area", position = "fill",
                     color = "black", size = 0.3) +
        #geom_area(position="fill", col="black") +
        scale_fill_manual(values =colors) +
        guides(fill = guide_legend(reverse = TRUE)) +
        labs(title="Proportions (average)",
             y="Proportion of aboveground biomass\n\n",
             x="Year")
    ### Structural complexity
    cohortPlot <-    ggplot(df, aes(x=Year, y=numCohorts, colour=species)) +
        geom_line(size=0.3, alpha = 0.4,  group = df$simID) +
        stat_summary(fun.y="mean", geom="line", size = 0.5) +
        scale_colour_manual(values=colors) +
        guides(fill = guide_legend(reverse = TRUE)) +
        labs(title="Structural complexity",
             y="Number of cohorts\n\n",
             x="Year")
    ### Shade classes
    shadePlot <- ggplot(shadeDf, aes(x=Year, y=value)) +
        geom_line(size=0.3, alpha = 0.4,  group = replicate) +
        stat_summary(fun.y="mean", geom="line", size = 0.5) +
        geom_segment(aes(x = 0, y = shadeThresh[-1],
                         xend = max(shadeDf$Year), yend = shadeThresh[-1]),
                     linetype = 3, size = 0.25) +
        annotate("text", label = paste0("ShadeClass", c(0:5)),
                 x = 1000, y = shadeThresh + 2,
                 hjust = 1, vjust = 0,
                 size = 2.5) +
        ylim(0,100) +
        #scale_colour_manual(values = "grey") +
        labs(title="Shade",
             y="Shade\n(% maxAGB)\n",
             x="Year")



    #############
    #### function that extract the legend of a gplot
    #############
    g_legend <- function(a.gplot){## a.gplot<-latGradPlot
        tmp <- ggplot_gtable(ggplot_build(a.gplot))
        leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
        legend <- tmp$grobs[[leg]]
        return(legend)
    }
    ### extract legend from one of the plot to get species
    plotLegend <- g_legend(fillPlot)


    #############
    #### defining layout
    require(grid)
    #############
    vpTitle <- viewport(x = 0, y = 1, width = 1, height = 0.1,  just=c("left", "top"))
    vpLine <- viewport(x = 0, y = 0.9, width = 0.8, height = 0.18, gp = gpar(fontsize=8), just=c("left", "top"))
    vpStack <- viewport(x = 0, y = 0.72, width = 0.8, height = 0.18, gp = gpar(fontsize=8), just=c("left", "top"))
    #vpLat <- viewport(x = 0.75, y = 0.8, width = 0.15, height = 0.65, just=c("left", "top"))
    vpFill <- viewport(x = 0, y = 0.54, width = 0.8, height = 0.18, gp = gpar(fontsize=8), just=c("left", "top"))

    vpCohorts <- viewport(x = 0, y = 0.36, width = 0.8, height = 0.18, gp = gpar(fontsize=8), just=c("left", "top"))
    vpShade <- viewport(x = 0, y = 0.18, width = 0.8, height = 0.18, gp = gpar(fontsize=8), just=c("left", "top"))

    vpLegend <- viewport(x = 0.8, y = 0.9, width = 0.2, height = 0.72, just=c("left", "top"))

    #     grid.show.viewport(vpTitle)
    #     grid.show.viewport(vpLine)
    #     grid.show.viewport(vpStack)
    #     grid.show.viewport(vpFill)
    #     grid.show.viewport(vpCohorts)
    #     grid.show.viewport(vpShade)
    #     grid.show.viewport(vpLegend)

    ### printing multiple plots on one figure

    png(filename = paste0("multiSppLandisSite_", a, "_", l, ".png"),
        width = 10, height =10,
        units = "in", pointsize = 6, bg = "white",
        res = 300)

        grid.newpage()
        upViewport(0)
        grid.text(paste0(title, "\nPixel-level simulations (", replicateN, " replicates)"),
                  gp=gpar(fontsize=16, col="black"),
                  just = "centre", vp=vpTitle)

        upViewport(0)
        print(linePlot + theme(plot.title = element_text(hjust = 0, size = 12),
                               legend.position="none",
                               legend.title=element_blank(),
                               axis.text.y = element_text(angle=90, hjust = 0.5),
                               axis.title.y = element_text(angle=90, size=8),
                               axis.text.x = element_text(angle = 0, hjust = 0.5, size=8),
                               axis.title.x = element_blank()), vp = vpLine)

        upViewport(0)
        print(stackPlot+ theme(plot.title = element_text(hjust = 0, size = 12),
                               legend.position="none",
                               axis.text.y = element_text(angle=90, hjust = 0.5),
                               axis.title.y = element_text(angle=90, size=8),
                               axis.text.x = element_text(angle = 0, hjust = 0.5, size=8),
                               axis.title.x = element_blank()), vp = vpStack)

        upViewport(0)
        print(fillPlot + theme(plot.title = element_text(hjust = 0, size = 12),
                               legend.position="none",
                               axis.text.y = element_text(angle=90, hjust = 0.5),
                               axis.title.y = element_text(angle=90, size=8),
                               axis.text.x = element_text(angle = 0, hjust = 0.5, size=8),
                               axis.title.x = element_blank()), vp = vpFill)

        upViewport(0)
        print(cohortPlot + theme(plot.title = element_text(hjust = 0, size = 12),
                                 legend.position="none",
                                 axis.text.y = element_text(angle=90, hjust = 0.5),
                                 axis.title.y = element_text(angle=90, size=8),
                                 axis.text.x = element_text(angle = 0, hjust = 0.5, size=8),
                                 axis.title.x = element_blank()), vp = vpCohorts)

        upViewport(0)
        print(shadePlot + theme(plot.title = element_text(hjust = 0, size = 12),
                                legend.position="none",
                                axis.text.y = element_text(angle=90, hjust = 0.5),
                                axis.title.y = element_text(angle=90, size=8),
                                axis.text.x = element_text(angle = 0, hjust = 0.5, size=8),
                                axis.title.x = element_blank()), vp = vpShade)

        upViewport(0)
        pushViewport(vpLegend)
        grid.draw(plotLegend)

    dev.off()
}