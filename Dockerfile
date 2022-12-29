FROM condaforge/mambaforge:4.10.3-1
MAINTAINER Shivvrat shivvrat.arya@utdallas.edu
RUN mamba install -c anaconda \
    numpy \
    jupyterlab \
    cython
RUN apt-get update && apt-get -y upgrade
RUN apt-get install -qq -y --no-install-recommends \
    git \
    wget
RUN git clone https://github.com/Shivvrat/ptg-particle-filtering.git
WORKDIR ptg-particle-filtering/project/
CMD ["jupyter-lab","--ip=0.0.0.0","--no-browser","--allow-root"]
