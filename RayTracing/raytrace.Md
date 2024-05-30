# "RayTracing"
ray tracing in roblox is not yet a thing but we can replicated how it works using rays and light and parts

### Explanation

So basically what I did in the [raytracing.lua](https://raw.githubusercontent.com/DeroXP/Roblox-stugg/main/RayTracing/raytrace.lua) file i've given it makes a whole bunch of blocks/cube and then puts them into a cube shape ehich follows around the character.

[<img src="https://static.vecteezy.com/system/resources/previews/000/375/576/large_2x/mp4-vector-icon.jpg" width="50%">](https://github.com/DeroXP/Roblox-stugg/raw/main/RayTracing/2024-05-30%2013-59-44.mp4 "Video")

with the cube they are orientatated so they are pointing the opposite direction of the sun this is to achieve lighting look a bit more realistic based on the sun and then we can also take account on other pre loaded lighting

### Rays

<img src="https://github.com/DeroXP/Roblox-stugg/blob/main/RayTracing/Screenshot%20(212).png?raw=true" width="50%">

In this screenshot there is about 90 rays coming out of each probe which are also correlated to the sun direction and they also have a spread to capture more color.
This is to get all colors rays capture and then average the color into the light which gives the lighting a more dynamic feel to it.

### Result

<img src="https://github.com/DeroXP/Roblox-stugg/blob/main/RayTracing/Screenshot%20(211).png?raw=true" width="50%">
