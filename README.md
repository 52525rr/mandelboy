# mandelboy
A mandelbrot set written by me for the original gameboy, in assembly.
This rom computes and renders 16 iterations of the mandelbrot set at 128\*128 resolution, taking ~27 seconds to do so. 

Since the gameboy is mainly an 8-bit system, I of course has to use 8 bit integers for fast calculations. The most amount of precision I could squeeze out of this thing is numbers represented at a granularity of 0.03125. That isnt very precise I know, but you wont see the lack of detail anyway because of the gameboy's low resolution. 

Also thanks to @koizeru for fixing overflow issues with this.

The rom can be assembled with RGBDS (and is what i used to make it).
![image](https://user-images.githubusercontent.com/89883425/156067391-5d1770ab-fb87-441d-b1d7-2cf40e1bea9c.png)
