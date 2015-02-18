is.installed <- function(mypkg){
    is.element(mypkg, installed.packages()[,1])
}

if (!is.installed("compare")){
    source("http://bioconductor.org/biocLite.R")
    biocLite(c('samr', 'devtools'))
    library(devtools)
    install_github('shka/R-SAMstrt')
    install.packages("compare", repos="http://cran.ism.ac.jp/")
}
