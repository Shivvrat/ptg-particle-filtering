# Commands to run docker file - 
docker build --no-cache -t ptg .
docker run --rm -it -p 8888:8888 ptg

# How to change recipe in the .ipynb file
In the second cell there is a variable called ```recipe_name``` which can be used to change the recipe. The options are - ```["Recipe A: Pinwheels", "Recipe B: Pour-over Coffee"]```

