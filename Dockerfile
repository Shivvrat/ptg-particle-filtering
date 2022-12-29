FROM condaforge/mambaforge:4.10.3-1
MAINTAINER Shivvrat shivvrat.arya@utdallas.edu
WORKDIR project/
RUN mamba install -c anaconda \
    numpy \
    jupyterlab \
    cython
#RUN pip install papermill
RUN apt-get update && apt-get -y upgrade
RUN apt-get install -qq -y --no-install-recommends \
    git \
RUN apt install --reinstall gcc
RUN git clone https://github.com/Shivvrat/ptg-particle-filtering.git
#RUN #papermill ParticleFiltering.ipynb output.ipynb
#CMD ["jupyter-lab","--ip=0.0.0.0","--no-browser","--allow-root"]
