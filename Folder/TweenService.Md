### TweenService

**this is a regular example below by chatgpt since im lazy**

---------------------------------------------------------------------
Certainly! Below is an example script that demonstrates how to create a toggle button in Roblox using the TweenService to tween a frame to a new position and back to its original position when clicked.

First, make sure you have a ScreenGui with a Frame and a TextButton inside it. You can set this up in Roblox Studio as follows:

1. Create a ScreenGui inside `StarterGui`.
2. Create a Frame inside the ScreenGui.
3. Create a TextButton inside the Frame.

Now, add a LocalScript inside the TextButton and use the following code:

```lua
local TweenService = game:GetService("TweenService")

-- References to the frame and the button
local frame = script.Parent.Parent
local button = script.Parent

-- Define the original and target positions
local originalPosition = UDim2.new(0.5, -50, 0.5, -50)
local targetPosition = UDim2.new(0.5, -50, 0.2, -50)

-- Define tween info
local tweenInfo = TweenInfo.new(
    0.5, -- Time
    Enum.EasingStyle.Quad, -- EasingStyle
    Enum.EasingDirection.Out, -- EasingDirection
    0, -- RepeatCount (0 means no repeat)
    false, -- Reverses (true means the tween will reverse once reaching its goal)
    0 -- DelayTime
)

-- Create tweens
local tweenToTarget = TweenService:Create(frame, tweenInfo, {Position = targetPosition})
local tweenToOriginal = TweenService:Create(frame, tweenInfo, {Position = originalPosition})

-- Track the current state
local isAtOriginalPosition = true

-- Set the frame's initial position
frame.Position = originalPosition

-- Function to toggle the frame position
local function togglePosition()
    if isAtOriginalPosition then
        tweenToTarget:Play()
    else
        tweenToOriginal:Play()
    end
    isAtOriginalPosition = not isAtOriginalPosition
end

-- Connect the function to the button's click event
button.MouseButton1Click:Connect(togglePosition)
```

### Explanation:

1. **TweenService Reference**: We get the `TweenService` to create tweens.
2. **Frame and Button References**: We get references to the `Frame` and `Button`.
3. **Positions**: We define the original and target positions for the `Frame`.
4. **TweenInfo**: We create a `TweenInfo` object to define the duration and style of the tween animation.
5. **Tweens**: We create two tweens: one to move the frame to the target position and another to move it back to the original position.
6. **State Tracking**: We use a boolean variable `isAtOriginalPosition` to track whether the frame is in its original position or not.
7. **Initial Position**: We set the frame's initial position.
8. **Toggle Function**: We define a function `togglePosition` to play the appropriate tween based on the current state and then toggle the state.
9. **Button Click Event**: We connect the `togglePosition` function to the button's `MouseButton1Click` event.

This script will make the frame move to a new position when the button is clicked and move back to its original position when clicked again, creating a toggle effect.
----------------------------------------------------------------------------
