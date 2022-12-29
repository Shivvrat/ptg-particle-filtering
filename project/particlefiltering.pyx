import numpy as np
cimport numpy as np
import cython
from libc.math cimport exp,log
from libc.stdlib cimport rand
cdef extern from "stdlib.h":
    double drand48()
    void srand48(long int seedval)
np.import_array()

@cython.boundscheck(False) # compiler directive
@cython.wraparound(False) # compiler directive
cdef unsigned int[:] get_max_marginal(unsigned int[:,:] samples, unsigned int nSamples, unsigned int nSteps):
  cdef unsigned long[:,:] marginals=np.zeros((nSteps,2),dtype=np.uint64)
  cdef unsigned int[:] max_vector=np.zeros(nSteps,dtype=np.uint32)
  cdef unsigned int i,j
  for i in range(nSamples):
    for j in range(nSteps):
      if samples[i,j]>0:
        marginals[j,1]+=1
      else:
        marginals[j,0]+=1
  for i in range(nSteps):
    if marginals[i,1]>marginals[i,0]:
      max_vector[i]=1
  return max_vector
@cython.boundscheck(False) # compiler directive
@cython.wraparound(False) # compiler directive
cdef np.float64_t[:,:] getAncestorFunction(unsigned int k):
    cdef np.float64_t[:,:] eFunction=np.zeros([2,2],dtype=np.float64)
    cdef double k_float=k*10
    # If your ancestor is false, then the likelihood that you
    # are true is low.
    eFunction[0,1]=log(1.0/k_float)
    return eFunction
@cython.boundscheck(False) # compiler directive
@cython.wraparound(False) # compiler directive
cdef np.float64_t[:,:] getDescendantFunction(unsigned int k):
    cdef np.float64_t[:,:] eFunction=np.zeros([2,2],dtype=np.float64)
    cdef double k_float=k*10
    # If your descendant is true, then the likelihood that you
    # are false is low
    eFunction[1,0]=log(1.0/k_float)
    return eFunction

@cython.boundscheck(False) # compiler directive
@cython.wraparound(False) # compiler directive
cdef np.float64_t[:,:] getEvidenceFunctions(np.float64_t[:] smax, unsigned int nSteps):
    cdef np.float64_t[:,:] eFunction=np.zeros([nSteps,2],dtype=np.float64)
    cdef unsigned int i
    for i in range(nSteps):
      if smax[i]>0.3:
        eFunction[i,1]=smax[i]
        eFunction[i,0]=log(0.001)
    return eFunction
@cython.boundscheck(False) # compiler directive
@cython.wraparound(False) # compiler directive
cdef np.float64_t myexpit(np.float64_t x):
  if x < -100:
    return 0.0
  if x > 100:
    return 1.0
  return 1.0/(1.0+exp(-x))


cdef class PF:
  # The dynamic graphical model is defined using:
  #     1. Univariate Priors over each step at time slice "t"
  #     2. Pairwise functions which link step at time "t" to "t+1"
  #     3. Evidence functions which take as input a continuous value
  #        and output the probability that the step was achieved at
  #        that step
  # for each step we have a prior; 2D array of size steps x 2
  # cdef np.float64_t[:,:] pFunctions
  # for each pair of steps we have a transition function;
  # 3D array of size steps x steps x 2 x 2
  cdef np.float64_t[:,:,:] tFunctions
  # topological sort of all the steps for sampling
  cdef unsigned int [:] topological_sort
  cdef unsigned int [:] critical_mask
  cdef unsigned int[:] num_functions
  cdef unsigned int[:,:] parents
  cdef unsigned int[:,:] function_ids
  # nodes connected to the current timeslice
  # number of steps and Samples
  cdef unsigned int nSteps
  cdef unsigned int nSamples

  cdef unsigned int [:,:] samples
  # Initialize the particle filter
  # Input:
  # 1. Edges is a 2-D array of directed edges where
  #       the second dimension is always 2
  #       For example, two directed edges
  #       1->3 and 4->5 will yield the following
  #       array edges[0][0]=1; edges[0][1]=3; and
  #       edges[1][0]=4 and edges[1][1]=5
  # 2. nSteps is the number of steps in the recipe
  # 3. nSamples is the number of samples
  def __init__(self,unsigned int[:,:] edges,unsigned int[:] critical_mask, unsigned int[:,:] step_array, unsigned int nSteps, unsigned int nSamples=1000):
    cdef unsigned int i,j,k,count,f,step_start,step_end,tmp
    cdef unsigned int nEdges=edges.shape[0]

    # Initialize class functions
    self.nSteps=nSteps
    self.nSamples=nSamples
    self.critical_mask=np.zeros(nSteps,dtype=np.uint32)
    self.tFunctions=np.zeros((nSteps*nSteps*2,2,2), dtype=np.float64)
    self.samples=np.zeros((nSamples,nSteps),dtype=np.uint32)
    self.topological_sort=np.arange(nSteps,dtype=np.uint32)
    self.num_functions=np.zeros(nSteps,dtype=np.uint32)
    self.function_ids=np.zeros((nSteps,nSteps),dtype=np.uint32)
    self.parents=np.zeros((nSteps,nSteps),dtype=np.uint32)

    self.critical_mask=critical_mask

    srand48(np.random.randint(100,1000000000))
    count=0
    for k in range(nEdges):
      i=edges[k,0]
      j=edges[k,1]
      if self.critical_mask[i]==0:
        f=self.num_functions[i]
        self.tFunctions[count,:,:]=getDescendantFunction(1)
        self.function_ids[i,f]=count
        self.parents[i,f]=j
        self.num_functions[i]+=1
        count+=1
      if self.critical_mask[j]==0:
        f=self.num_functions[j]
        self.tFunctions[count,:,:]=getAncestorFunction(1)
        self.function_ids[j,f]=count
        self.parents[j,f]=i
        self.num_functions[j]+=1
        count+=1

    for i in range(nSteps):
      f=self.num_functions[i]
      self.tFunctions[count,0,1]=log(0.01)
      self.tFunctions[count,1,0]=log(0.01)
      self.function_ids[i,f]=count
      self.parents[i,f]=i
      self.num_functions[i]+=1
      count+=1


    for i in range(step_array.shape[0]):
      step_start=step_array[i,0]
      step_end=step_array[i,1]
      tmp=step_start
      for j in range(step_start,step_end+1):
        if self.critical_mask[j]>0:
          for k in range(tmp,j):
            f=self.num_functions[k]
            self.tFunctions[count,:,:]=getDescendantFunction(1)
            self.function_ids[k,f]=count
            self.parents[k,f]=j
            self.num_functions[k]+=1
            count+=1
          tmp=j+1

  @cython.boundscheck(False) # compiler directive
  @cython.wraparound(False) # compiler directive
  cdef np.float64_t[:] get_distribution(self,unsigned int n, unsigned int var, np.float64_t[:] efunc):
    cdef unsigned int i,f,pid
    cdef np.float64_t[:] dis=np.zeros(2,dtype=np.float64)
    cdef np.float64_t val_0=0.0,val_1=0.0


    # incorporate transition
    for i in range(self.num_functions[var]):
      f=self.function_ids[var,i]
      pid=self.parents[var,i]
      val_0+=self.tFunctions[f,self.samples[n,pid],0]
      val_1+=self.tFunctions[f,self.samples[n,pid],1]
    # incorporate current evidence
    val_0+=efunc[0]
    val_1+=efunc[1]
    dis[0]=myexpit(val_0-val_1)
    dis[1]=1.0-dis[0]
    return dis

  # Updat the distribution
  # 1. smax: softmax over the steps
  @cython.boundscheck(False) # compiler directive
  @cython.wraparound(False) # compiler directive
  cpdef unsigned int[:] update(self,np.float64_t[:] smax):
    cdef unsigned int [:,:] newSamples=np.zeros([self.nSamples,self.nSteps],dtype=np.uint32)
    cdef unsigned int n,j,var
    cdef np.float64_t[:] p
    cdef np.float64_t[:,:] eFunctions=getEvidenceFunctions(smax,self.nSteps)
    for n in range(self.nSamples):
        for j in range(self.nSteps):
          var=self.topological_sort[j]
          p=self.get_distribution(n,var,eFunctions[var])
          if drand48()>p[0]:
            newSamples[n,var]=1
    self.samples=newSamples
    return get_max_marginal(self.samples,self.nSamples, self.nSteps)

  @cython.boundscheck(False) # compiler directive
  @cython.wraparound(False) # compiler directive
  cpdef unsigned int[:] updateGivenDone(self,unsigned int stepid):
    cdef unsigned int i,n
    for i in range(self.nSteps):
      for n in range(self.nSamples):
        if i>stepid:
          self.samples[n,i]=0
        else:
          self.samples[n,i]=1
    return get_max_marginal(self.samples,self.nSamples, self.nSteps)

  @cython.boundscheck(False) # compiler directive
  @cython.wraparound(False) # compiler directive
  cpdef unsigned int[:] updateGivenNone(self):
    return get_max_marginal(self.samples,self.nSamples, self.nSteps)
