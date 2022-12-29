# Graph Creation
Input - A recipe with mulitple steps.
E.g. - "Recipe B: Pour-over Coffee" from the PTG Cookbook

## Steps to create the dependency graph - 
1. First we divide the steps into smaller sub-steps (But if the steps in the recipe are small enough you can skip this step). For example -  
	**STEP** - 
	Use a butter knife to scoop nut butter from the jar. Spread 	nut butter onto tortilla, leaving 1/2-inch uncovered at the 	edges

	**SUB-STEPS**
	1. Take butter knife
	2. Take nut butter jar
	3. Scoop nut butter from butter jar using butter knife
	4. Spread nut butter on tortilla

	This helps us to create better dependencies and the (**atomic**) sub-steps helps us to train a better feature extractor (since we have more fine-grained activities).

2. For all the sub-steps we need figure out the sub-steps that are required to be finished before we can start the current sub-step.
For the sub-steps shown above, we can perform 1 and 2 in any order, but to accomplish 3 we need to first complete the first two. 

This gives us a **dependeny graph** of the recipe sub-steps - a graph which shows the order of the steps and if we parse this graph in a topological order it would give us an ordering which would represent the recipe being performed correctly. 

To create this graph we need to think about the following (for each sub-step)- 
1. What are the other sub-steps without which we cannot finish the current one. 
2. We add edges to the graph incrementally as we process more and more sub-steps. 
3. We also add edges for the sub-steps at the extremities of the steps, i.e. if the last sub-step of step 2 is 5, then we add an edge from 5 to 6 (this helps the particle filtering the reduce its dependence on the feature extractor).
4. We need to represent this graph in a edge matrix which is defined in more detail below.

As of now we are creating the graph by hand by looking at the recipe sub-steps and then using knowledge about the recipe! 

In the code we load the dependency graph in the variable *edges*. This is a |E| * 2 matrix, which represents the start and end points of each edge. 

## Important Patterns - 
There are a few important patterns that we saw while creating the graph - 
1. There is a sequential progression for all the sub-steps in each step. 
2. There might be cases where consecutive steps might not be dependent on each other, but eventually there would be a step which would be dependent on the given step. 
3. Adding sub-steps when we change steps helps stabalize the particle filtering code. 



# Critical Mask
We also classify each sub-step into critical and non-critical categories. 

A **critical sub-step** is essential for its corresponding step to be finished. In the example given above sub-step 3 and sub-step 4 are the critical sub-steps (since we can already have the knife and butter jar in hand or nearby, but scooping the butter and spreading it on the tortilla is necessary for the success of this step) for the given step. 

# Step Array
The step array comprises of the index of the first and last sub-steps for a given step. The size of the step array would be |Number of Steps| * 2, since we will have start and end sub-step indices for each step. 


# Steps and Sub-Steps for the Recipes from PTG Cookbook- 
## Recipe A: Pinwheels
For this recipe we divided the step 11 into further steps to make the process easier. 

### Steps - 

1. Place tortilla on cutting board.
2. Use a butter knife to scoop nut butter from the jar.  Spread nut butter onto tortilla, leaving 1/2-inch uncovered at the edges.
3. Clean the knife by wiping with a paper towel.
4. Use the knife to scoop jelly from the jar. Spread jelly over the nut butter.
5. Clean the knife by wiping with a paper towel.
6. Roll the tortilla from one end to the other into a log shape, about 1.5 inches thick. Roll it tight enough to prevent gaps, but not so tight that the filling leaks.
7. Secure the rolled tortilla by inserting 5 toothpicks about 1 inch apart.
8. Trim the ends of the tortilla roll with the butter knife, leaving ½ inch margin between the last toothpick and the end of the roll. Discard ends.
9. Slide floss under the tortilla, perpendicular to the length of the roll. Place the floss halfway between two toothpicks.
10. Cross the two ends of the floss over the top of the tortilla roll. Holding one end of the floss in each hand, pull the floss ends in opposite directions to slice.
11. Continue slicing with floss to create 5 pinwheels.
12. Place the pinwheels on a plate.

### Sub-Steps - 

Step 1:
1. Take Cutting Board
2. Place tortilla on cutting board
Step 2:
1. Take butter knife
2. Take nut butter jar
3. Scoop nut butter from butter jar using butter knife
4. Spread nut butter on tortilla
Step 3:
1. Take the paper towel
2. Clean the butter knife using paper towel
Step 4:
1. Take butter knife
2. Take jelly jar
3. Scoop jelly from jelly jar using butter knife
4. Spread jelly on tortilla
Step 5:
1. Take the paper towel
2. Clean the butter knife using paper towel
Step 6:
1. Tightly roll the tortilla
Step 7:
1. Take the toothpicks
2. Insert 5 toothpicks into the tortilla
Step 8:
1. Trim the ends of the tortilla roll with the butter knife on both sides
Step 9:
1. Take floss
2. Place floss under the tortilla halfway between the two toothpicks
Step 10:
1. Cross the two ends of the floss over the top of the tortilla roll
2. Pull the floss to cut the tortilla
Step 11:
1. Continue slicing with floss to create the second pinwheel.  (Repeat 10)
Step 12:
1. Continue slicing with floss to create the third pinwheel.  (Repeat 10)
Step 13:
1. Continue slicing with floss to create fourth and fifth pinwheels.  (Repeat 10)
Step 14:
1. Take the plate
2. Place the pinwheels on the plate

## Recipe B: Pour-over Coffee

### Steps - 

1. Measure 12 ounces of cold water and transfer to a kettle.
2. Assemble the filter cone.  Place the dripper on top of a coffee mug.
3. Prepare the filter insert by folding the paper filter in half to create a semi-circle, and in half again to create a quarter-circle.  Place the paper filter in the dripper and spread open to create a cone.
4. Weigh the coffee beans and grind until the coffee grounds are the consistency of coarse sand, about 20 seconds. Transfer the grounds to the filter cone.
5. Check the temperature of the water.
6. Pour a small amount of water in the filter to wet the grounds. Wait about 30 seconds.
7. Slowly pour the rest of the water over the grounds in a circular motion. Do not overfill beyond the top of the paper filter.
8. Let the coffee drain completely into the mug before removing the dripper. Discard the paper filter and coffee grounds.

### Sub-Steps - 

Step 1:
1. Take bowl
2. Fill water using measure bowl
3. Take kettle
4. Open the lid of kettle
5. Pour water
6. Close the lid of kettle
Step 2:
1. Take Filter cone
2. Take mug
3. Place the filter cone on top of mug
Step 3:
1. Take Paper filter
2. Prepare Paper filter half
3. Prepare Paper filter quarter
4. Put Paper filter into dripper
Step 4:
1. Take the kitchen scale
2. Take the coffee beans with container on the scale
3. Take the coffee grinder
4. Open the coffee grinder
5. Pour the coffee beans into the grinder
6. Cover the lid of grinder
7. Grind coffee beans
8. Take the dripper
9. Open the coffee grinder
10. Transfer the grounds to the filter cone
Step 5:
1. Take kettle
2. Open the lid of kettle
3. Take the thermometer
4. Put the thermometer into kettle
5. Take out the thermometer
6. Close the lid of kettle
Step 6:
1. Take the dripper with grounds coffee
2. Pour a small amount of water into dripper
Step 7:
1. Pour the rest of the water over the grounds in a circular motion
Step 8:
1. Removing the dripper
2. Discard the paper filter and coffee grounds.