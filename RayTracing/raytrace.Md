# RayTrace
**Ray tracing** in **Roblox** is not yet a native feature, but we can replicate its effects using **rays**, **light**, and **parts**.

### Explanation

In the [**raytracing.lua**](https://raw.githubusercontent.com/DeroXP/Roblox-stugg/main/RayTracing/raytrace.lua) file provided, I've created a system that generates a **cube** of **blocks**. These blocks are positioned around the **character**, forming a **cube** shape. 

<img src="https://github.com/DeroXP/Roblox-stugg/blob/main/RayTracing/2024-05-30%2013-59-44.gif?raw=true" width="100%">

The cubes are oriented to face away from the **sun** to achieve more realistic **lighting** based on **sunlight**. Additionally, the system accounts for other pre-loaded **lighting conditions** (not yet).

### **Rays**

![Rays](https://github.com/DeroXP/Roblox-stugg/blob/main/RayTracing/Screenshot%20(212).png?raw=true)

In the screenshot above, approximately 90 **rays** are emitted from each **probe**. These **rays** are oriented in the direction of the **sun** and have a spread to capture a wide range of colors. This dynamic approach to capturing light colors enhances the realism of the **lighting**.

### Result

![Result](https://github.com/DeroXP/Roblox-stugg/blob/main/RayTracing/Screenshot%20(211).png?raw=true)

The result is a visually stunning real-time generated **lighting effect**.

### Methods

To achieve this, we first create a **cube** of **probes** and make them follow the **character's position** using `RootPart`. Then, we orient the cubes based on the **sun's direction**. **Rays** are emitted from the **probes**, traveling in the opposite direction of the **sun** until they encounter an **object**. Upon hitting an **object**, the **ray** captures the object's **color** (if available) or resorts to the **color** of the **atmosphere**. The colors captured by the **rays** are combined and averaged to create a suitable **lighting color** for the environment. Additionally, we account for the **brightness** of the **lighting** by shooting another **ray** towards the **sun**. If this **ray** is blocked by an **object**, the **lighting** is dimmed accordingly.

One challenge we faced was the appearance of bright spots when **probes** were too close to **objects**. To address this, we adjusted the **brightness** of the **lighting** based on proximity to **objects**, ensuring a more realistic effect. Another challenge was ensuring accurate **lighting** when transitioning between indoor and outdoor environments. We solved this by having **probes** check the **brightness** of neighboring **probes** and adjusting their own **brightness** accordingly.

### Services

1. [**TweenService**](https://create.roblox.com/docs/reference/engine/classes/TweenService)
2. [**RunService**](https://create.roblox.com/docs/reference/engine/classes/RunService)
3. [**Lighting**](https://create.roblox.com/docs/reference/engine/classes/Lighting)
4. [**ReplicatedStorage**](https://create.roblox.com/docs/reference/engine/classes/ReplicatedStorage)

# Credits

I didn't come up with this idea fully I saw another person [From This Video](https://www.youtube.com/watch?v=_dhz0PhVtv8) and since it was not open-sourced i decided to try it myself and actually got somewhere so credits to that person and also credits to me for doing this.

### Notice

**Sorry I have to get rid of the source code and it will not come back.**
