is.installed <- function(mypkg){
    is.element(mypkg, installed.packages()[,1])
}

if (!is.installed("edgeR")){
	install.packages('dplyr')
	install.packages('plyr')
	install.packages('tidyr')
	install.packages('stringr')

	source("http://bioconductor.org/biocLite.R")
	biocLite("Mus.musculus")
	biocLite("limma")
	biocLite("edgeR")
}
