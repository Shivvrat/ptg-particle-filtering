# Commands to run docker file - 
```
docker build --no-cache -t ptg .
docker run --rm -it -p 8888:8888 ptg
```

# How to change recipe in the .ipynb file
In the second cell there is a variable called ```recipe_name``` which can be used to change the recipe. The options are - ```["Recipe A: Pinwheels", "Recipe B: Pour-over Coffee"]```

# How to start the jupyter-lab 
When you run the second command the you will see the jupyter-lab URL in the terminal. Please click on that/copy and paste it in a browser window. We are running the jupyter-lab session in --no-browser mode so that we can access the GUI.  

# Steps to run code - 
1. After getting into jupyter-lab please open the file named ```ParticleFiltering.ipynb```.
2. After that please select the recipe you want to run the code for in the second cell. (The options are given as a comment on the right)
3. All the data and other parts of the code are loaded automatically.
4. Please run all the cells in the jupyter-lab
5. The output of the PF model should be printed in the last cell. (We also print some other useful information in the last cell)

# What does the output represent - 
- The size of the output will be |number of sub-steps|.
- Each value represents the state of the sub-step at the current time stamp. 
- The values that the state can take are - 
  - ```0``` - If the sub-step is not done.
  - ```1``` - If the sub-step has been finished.  