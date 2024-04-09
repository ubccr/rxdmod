
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
# Other
conda install -y 'pymysql' 'requests'
```

If you don’t have R yet you can install it with conda too:

``` bash
# r-notebook  r=4.3
conda install -y 'r-base' 'r-caret' 'r-crayon' 'r-devtools' 'r-e1071' \
    'r-forecast' 'r-hexbin' 'r-htmltools' 'r-htmlwidgets' 'r-irkernel' \
    'r-nycflights13' 'r-randomforest' 'r-rcurl' 'r-rmarkdown' 'r-rodbc' \
    'r-rsqlite' 'r-shiny' 'r-tidymodels' 'r-tidyverse' 'unixodbc'

# Other
conda install -y \
    'r-plotly' 'r-repr' 'r-irdisplay' 'r-pbdzmq' 'r-reticulate' 'r-cowplot' \
    'r-rjson' 'r-dotenv'
```

### Set up XDMoD API Token

#### Obtain an API token

You will need to get XDMoD-API token in order to access XDMoD Analytical
Framework.

Follow [these
instructions](https://github.com/ubccr/xdmod-data#api-token-access) to
obtain an API token.

#### Store the API token in .Renveron (The R-Way)

Write the token to `~/.Renviron` file:

``` bash
cat >> ~/.Renviron << EOF
XDMOD_API_TOKEN=<my secret xdmod api token>
EOF
```

It will be loaded automatically (you might need to restart R-session at
first use).

#### Alternatively Store the API token at Same Place as XDMoD Python API

If you use XDMoD Python API as well then storing token in same file as
in Python API can be handy.

Write the token to `~/xdmod-data.env` file:

``` bash
cat >> ~/xdmod-data.env << EOF
XDMOD_API_TOKEN=<my secret xdmod api token>
EOF
```

Load it in your R-session, before calling `xdmod_get_datawarehouse`:

``` r
library(dotenv)
# on windows ~ points to Documents, adjust accordingly
load_dot_env(path.expand("~/xdmod-data.env"))
```

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

<img src="man/figures/README-unnamed-chunk-4-1.png" width="100%" />
