FROM condaforge/mambaforge:4.10.3-1
MAINTAINER Shivvrat shivvrat.arya@utdallas.edu
WORKDIR /project

RUN mamba install -c anaconda \
    numpy \
    jupyterlab \
    cython
RUN apt-get update && apt-get -y upgrade \
  && apt-get install -y --no-install-recommends \
    git \
    wget \
RUN git clone https://github.com/Shivvrat/ptg-particle-filtering.git
RUN cd ptg-particle-filtering/
RUN python pf/setup.py build_ext --inplace
CMD ["jupyter-lab","--ip=0.0.0.0","--no-browser","--allow-root"]
