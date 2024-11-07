Runtime analysis:


| Size   | CPU        | Naive GPU   | Advanced GPU  |
|--------|------------|-------------|---------------|
| 128    | 0.000021 ns| 0.000417 ns | 0.000273 ns   |
| 256    | 0.000076 ns| 0.00081 ns  | 0.000274 ns   |
| 1024   | 0.001232 ns| 0.00708 ns  | 0.000270 ns   |


This table shows that as the size increases, the Advanced GPU or recurisve doubling method begins to work much faster than the other methods. This makes sense at with more blocks, and numbers to sum, GPU can take better advantage of its capabilities running mulitple blocks simulainiously. My graph did match my expectations, with the GPU performing better as the size went up.

The CPU and Naive GPU versions made sense to me and were somewhat easy to compile. 

I struggled much more with conceptually understanding recursive doubling, especially the part where it offsets the values. 

I would allocate more time for the recursive doubling, because that was the most difficult part. I also think I would do more testing to see how the different version perform with even bigger numbers.

