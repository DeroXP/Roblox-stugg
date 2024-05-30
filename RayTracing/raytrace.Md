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

Now we get pretty beautiful real-time generated light coloring.

### Methods

To accomplish most of this we first create our cube of probes then we make probes follow the positiong of the character using `RootPart` and then we orientate those cubes based on the sun. Rays are added to the probe frequently and the rays shoot opposite from the sun direction until it runs into an object and when it hits object it finds the color of that object (if there is color), if no color is found the lighting will resort to the color of the atmosphere. now once we have gotten color the rays of the probe will get the color and then the color of the rays that are found are basically combined and averaged out into a color that should br fitting for that enviroment (because lighting would be more related to the enviroment color). and then we take in account of the brightness of the lighting meaning we shoot another ray but this time it goes towards the sun and if it is being blocked by an object it determines that the lighting should be dimmed and not as bright is it wasn't blocked. There was also a problem that was actually easily fixable so if a probe was to close to an object it would look weird because of the object being close meaning there would be a bright light dot on the floor so to fix this we just adjust brightness of the lighting to how close to an object it is and if too close it would be very dimmed. Another problem would be that when the player would go inside a building some probes where outside of the building still but every close to the interior which would amke the interior very brihgt instead of dim like it should have been so logic that was added was a probe would check other probes for the brightness and then relate to that brightness.
