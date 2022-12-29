import numpy
from setuptools import setup
from Cython.Build import cythonize

setup(
    name='Particle Filtering',
    ext_modules=cythonize("./pf/particlefiltering.pyx"),
    include_dirs=[numpy.get_include()],
    extra_compile_args=["-O3"]
    # zip_safe=False,
)

# Command to run -
# python setup.py build_ext --inplace