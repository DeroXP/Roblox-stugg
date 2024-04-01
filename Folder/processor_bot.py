import multiprocessing
import time
import tkinter as tk
from PIL import ImageGrab, ImageOps
import keyboard
import numpy as np
import os
import json

class Dot:
    def __init__(self, canvas, x, y, key):
        self.canvas = canvas
        self.x = x
        self.y = y
        self.key = key
        self.size = 10
        self.draw()

    def draw(self):
        x0 = self.x - self.size
        y0 = self.y - self.size
        x1 = self.x + self.size
        y1 = self.y + self.size
        self.object_id = self.canvas.create_oval(x0, y0, x1, y1, fill="white")
        self.canvas.tag_bind(self.object_id, '<ButtonPress-1>', self.on_click)
        self.canvas.tag_bind(self.object_id, '<B1-Motion>', self.on_drag)

    def on_click(self, event):
        self.start_x = event.x
        self.start_y = event.y

    def on_drag(self, event):
        self.x += event.x - self.start_x
        self.y += event.y - self.start_y
        self.canvas.coords(self.object_id,
                           self.x - self.size,
                           self.y - self.size,
                           self.x + self.size,
                           self.y + self.size)
        self.start_x = event.x
        self.start_y = event.y

def save_dot_positions(dots):
    dot_positions = []
    for dot in dots:
        dot_positions.append({'x': dot.x, 'y': dot.y, 'key': dot.key})
    with open('dot_positions.json', 'w') as f:
        json.dump(dot_positions, f)

def load_dot_positions():
    dot_positions = []
    if os.path.exists('dot_positions.json'):
        with open('dot_positions.json', 'r') as f:
            dot_positions = json.load(f)
    return dot_positions

def check_color(x, y, key, q_pressed, terminate_event):
    while not terminate_event.is_set():
        try:
            if q_pressed.is_set():
                # Grab the screen image at the coordinates around the dot
                screen_image = ImageGrab.grab(bbox=(x - 1, y - 1, x + 2, y + 2))

                # Convert the image to grayscale using PIL
                grayscale_image = ImageOps.grayscale(screen_image)

                # Convert the grayscale image to a numpy array for faster processing
                grayscale_array = np.array(grayscale_image)

                # Calculate the average grayscale value
                avg_grayscale = np.mean(grayscale_array)

                # Check if the average grayscale value is below a threshold
                threshold = 5  # Adjusted threshold
                if avg_grayscale < threshold:
                    # Perform double check by examining pixel values
                    if np.all(grayscale_array < 50):  # Check if all pixel values are below 50 (considered black)
                        print(f"Position ({x}, {y}) is black.")
                        if key in ['d', 'f', 'j', 'k']:
                            keyboard.release(key)
                    else:
                        print(f"Position ({x}, {y}) is not black.")
                else:
                    print(f"Position ({x}, {y}) is not black.")
                    print(f"Key {key} is pressed for dot at position ({x}, {y}).")

                    if key in ['d', 'f', 'j', 'k'] and q_pressed.is_set():
                        keyboard.press(key)

        except Exception as e:
            print(f"Error in color checking process: {e}")

        # Introduce a small delay to control the speed of the loop
        time.sleep(0.001)  # Adjust the delay time as needed

def key_monitor(q_pressed, terminate_event):
    q_toggle = False
    while not terminate_event.is_set():
        if keyboard.is_pressed('q'):
            q_toggle = not q_toggle
            if q_toggle:
                q_pressed.set()
            else:
                q_pressed.clear()
            time.sleep(0.2)  # debounce delay
        time.sleep(0.01)  # sleep to avoid high CPU usage

def main():
    # Create dots and map them to keys
    dots = []

    root = tk.Tk()
    root.attributes("-alpha", 0.5)  # Set transparency of the window
    root.attributes("-fullscreen", True)  # Make window full screen
    root.configure(bg='black')  # Set background color to black
    
    screen_width = root.winfo_screenwidth()
    screen_height = root.winfo_screenheight()
    
    canvas = tk.Canvas(root, width=screen_width, height=screen_height, bg='black', highlightthickness=0)
    canvas.pack()

    terminate_event = multiprocessing.Event()
    q_pressed = multiprocessing.Event()

    def on_close():
        terminate_event.set()
        save_dot_positions(dots)
        root.destroy()

    root.protocol("WM_DELETE_WINDOW", on_close)

    def place_dot(event):
        nonlocal dots
        if len(dots) < 4:
            key = ['d', 'f', 'j', 'k'][len(dots)]  # 'd', 'f', 'j', 'k'
            dot = Dot(canvas, event.x, event.y, key)
            dots.append(dot)
            # Start a process for checking color for this dot
            check_color_process = multiprocessing.Process(target=check_color, args=(event.x, event.y, key, q_pressed, terminate_event))
            check_color_process.daemon = True
            check_color_process.start()
            print(f"Dot placed at position ({event.x}, {event.y}) with key '{key}' assigned.")

    canvas.bind('<Button-1>', place_dot)

    # Load previously saved dot positions
    dot_positions = load_dot_positions()
    for pos in dot_positions:
        dot = Dot(canvas, pos['x'], pos['y'], pos['key'])
        dots.append(dot)
        # Start a process for checking color for this dot
        check_color_process = multiprocessing.Process(target=check_color, args=(pos['x'], pos['y'], pos['key'], q_pressed, terminate_event))
        check_color_process.daemon = True
        check_color_process.start()

    # Start process for monitoring 'q' key press
    key_monitor_process = multiprocessing.Process(target=key_monitor, args=(q_pressed, terminate_event))
    key_monitor_process.daemon = True
    key_monitor_process.start()

    root.mainloop()

if __name__ == "__main__":
    main()

#chatgpt used for side notes by DeroVB (https://github.com/DeroXP)
