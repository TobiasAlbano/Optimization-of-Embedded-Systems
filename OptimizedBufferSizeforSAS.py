import math as m

#Initialzing Node Representation of the SDF. Each sub-list is an Actor in the for [Token Consumption, Token Generation] for a single firing
SDF = [[0, 3], [4, 5], [3, 6], [5, 2], [3, 0]]
#Minimum Appearances by node for the Periodic Static Schedule
MinAppeareancesPSS = [4, 3, 5, 6, 4]

##############################################################################################################################################
#Calculating the GCD for number of firings needed for no token overflow for a given subchain of the SDF

GCD = [ [ 0 for _ in range(len(SDF)) ]  for _ in range(len(SDF)) ]

for i in range(len(SDF)):
  GCD[i][i] = MinAppeareancesPSS[i]
  for j in range(i + 1, len(SDF)):
    GCD[i][j] = m.gcd(GCD[i][j-1], MinAppeareancesPSS[j])

#GCD: [[4, 1, 1, 1, 1], 
#      [0, 3, 1, 1, 1], 
#      [0, 0, 5, 1, 1], 
#      [0, 0, 0, 6, 2], 
#      [0, 0, 0, 0, 4]]
##############################################################################################################################################
#Initializing DP Tables to be filled in the following loop

numActors = len(SDF)
Subcosts = [ [ 0 for _ in range(numActors) ]  for _ in range(numActors) ]
SplitPositions = [ [ 0 for _ in range(numActors) ]  for _ in range(numActors) ]

infinity = float('inf')

##############################################################################################################################################
#Filling DP Tables. Iterating through all possible subchains. In each subchain, iterating through all possible splits to determine optimal
#split position for smallest buffer size requirement

for sizeOfChain in range(2, numActors + 1): #Subchains must be at least of size 2 and at most the length of the entire SDF
  for rightSplitSize in range(sizeOfChain - 1, numActors): #Our right side can be at most as long as the SDF
    leftSplitSize = rightSplitSize - sizeOfChain + 1

    #Intial values of DP tables
    minCost = infinity
    bestSplit = -1

    for position in range(sizeOfChain - 1): #Checking each potential split position

      splitPosition = leftSplitSize + position

      ###############Where the magic happens###############
      splitPositionCost = (    (MinAppeareancesPSS[splitPosition] * SDF[splitPosition][1])
                              // GCD[leftSplitSize][rightSplitSize]     )

      totalCost = (     splitPositionCost + Subcosts[leftSplitSize][splitPosition] +
                   Subcosts[splitPosition + 1][rightSplitSize]     )

      #Only update if this split is better
      if totalCost < minCost:
        minCost = totalCost
        bestSplit = position

    #Update to match scenario given by best split
    Subcosts[leftSplitSize][rightSplitSize] = minCost
    SplitPositions[leftSplitSize][rightSplitSize] = bestSplit

#Subcosts: [[0, 12, 27, 57, 63], 
#          [0, 0, 15, 45, 51], 
#          [0, 0, 0, 30, 36], 
#          [0, 0, 0, 0, 6], 
#          [0, 0, 0, 0, 0]]

#SplitPositions: [[0, 0, 0, 0, 0], 
#                [0, 0, 0, 0, 0], 
#                [0, 0, 0, 0, 0], 
#                [0, 0, 0, 0, 0], 
#                [0, 0, 0, 0, 0]]

#minCost: 63

##############################################################################################################################################
#Building the schedule using the DP Tables

Actors = ['A', 'B', 'C', 'D', 'E'] #Naming the nodes to match the given SDF

def ConvertSplit(Left, Right):
  #Base case: if the "subchain" we are examining is a single node
  if (Left == Right):
    return Actors[Left]

  split = SplitPositions[Left][Right] #using the DP Table to find the optimal split position

  leftMult = GCD[Left][Left + split] // GCD[Left][Right] #It may be more optimal repeat a schedule of several nodes.
  rightMult = GCD[split+1+Left][Right] // GCD[Left][Right]

  #Recursive Call. After we have the optimal split position, find the optimal schedule on both sides.
  LeftSchedule = str(ConvertSplit(Left, Left+split))
  RightSchedule = str(ConvertSplit(split+1+Left, Right))

  #Formatting for readability
  if leftMult != 1:
    LeftSchedule = f"({leftMult}{LeftSchedule})"
  if rightMult != 1:
    RightSchedule = f"({rightMult}{RightSchedule})"

  #Returns the final schedule
  return f"{LeftSchedule} {RightSchedule}"

#Buffer-Optimized Single-Appearance Schedule: (4A) (3B) (5C) (2(3D) (2E))

