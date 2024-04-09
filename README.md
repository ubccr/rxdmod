
<!-- README.md is generated from README.Rmd. Please edit that file -->

# RXDMoD - R API for XDMoD Data Analytics Framework

Version: 1.0.0

As part of the XDMoD Data Analytics Framework, this R package provides
API access to the data warehouse of an instance of XDMoD.

<!-- badges: start -->
<!-- badges: end -->

## Installation

### Install Python API

First, you need to install python with pandas. Bellow is pandas-jupyter
complete environment for data-analysis. It is probably overkill for just
forwarding requests through XDMoD Python API, but it can be a good
choice for cross-language developments/work.

``` bash
# create a new conda environment called "xdmod-notebooks"
conda create -n xdmod-notebooks -y python=3.11
conda activate xdmod-notebooks
# base-notebook
conda install -y 'jupyterlab' 'notebook' 'jupyterhub' 'nbclassic'
# scipy-notebook
conda install -y  'altair' 'beautifulsoup4' 'bokeh' 'bottleneck' 'cloudpickle' \
    'conda-forge::blas=*=openblas' \
    'cython' 'dask' 'dill' 'h5py' 'ipympl' 'ipywidgets' 'jupyterlab-git' \
    'matplotlib-base' 'numba' 'numexpr' 'openpyxl' 'pandas' 'patsy' 'protobuf' \
    'pytables' 'scikit-image' 'scikit-learn' 'scipy' 'seaborn' 'sqlalchemy' \
    'statsmodels' 'sympy' 'widgetsnbextension' 'xlrd'
```

``` bash
# r-notebook  r=4.3
conda install -y 'r-base' 'r-caret' 'r-crayon' 'r-devtools' 'r-e1071' \
    'r-forecast' 'r-hexbin' 'r-htmltools' 'r-htmlwidgets' 'r-irkernel' \
    'r-nycflights13' 'r-randomforest' 'r-rcurl' 'r-rmarkdown' 'r-rodbc' \
    'r-rsqlite' 'r-shiny' 'r-tidymodels' 'r-tidyverse' 'unixodbc'

# Other
conda install -y 'pymysql' 'requests' \
    'r-plotly' 'r-repr' 'r-irdisplay' 'r-pbdzmq' 'r-reticulate' 'r-cowplot' \
    'r-rjson' 'r-dotenv'
```

### Set up XDMoD API Token

### Instal RXMoD

You can install the development version of rxdmod from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("ubccr/rxdmod")
```

## Example

``` r
library(tidyverse)
library(plotly)

# replace xdmod-notebooks with conda enviroment for python to use
library(reticulate)
use_condaenv("xdmod-notebooks")

library(rxdmod)
```

``` r
# Get XDMoD connection
dw <- xdmod_get_datawarehouse('https://xdmod.access-ci.org')

# Get Data of Interest
df <- xdmod_get_data(dw,
        duration=c('2023-01-01', '2023-03-31'),
        realm='Jobs',
        metric='Number of Users: Active'
    )
```

Plot the data

``` r
ggplot(df, aes(x=Time,y=`Number of Users: Active`)) +
        geom_line()
```

<img src="man/figures/README-unnamed-chunk-3-1.png" width="100%" />
