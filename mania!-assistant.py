import multiprocessing
import time
import tkinter as tk
from PIL import ImageGrab, ImageOps
import keyboard
import numpy as np
import os
import json
import cv2

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

def check_color(x, y, key, q_pressed, terminate_event, status, area_width=2, area_height=35, threshold=30): # chagne threshold to lower values for better ai 30 is around the regular us osu! player and 1 is i say a advanced osu player haven't quite gotten to get a bot that has zero mistakes...
    while not terminate_event.is_set():
        try:
            if q_pressed.is_set():
                # Grab the screen image with an expanded bounding box around the dot
                screen_image = np.array(ImageGrab.grab(bbox=(x - area_width, y - area_height, x + area_width, y + area_height)))

                # Convert the image to grayscale using OpenCV
                grayscale_image = cv2.cvtColor(screen_image, cv2.COLOR_BGR2GRAY)

                # Check if black color is detected
                if np.mean(grayscale_image) < threshold:
                    print(f"Position ({x}, {y}) is black.")
                    keyboard.release(key)
                else:
                    print(f"Position ({x}, {y}) is not black.")
                    print(f"Key {key} is pressed for dot at position ({x}, {y}).")

                    if key in ['d', 'f', 'j', 'k'] and q_pressed.is_set():
                        keyboard.press(key)

        except Exception as e:
            print(f"Error in color checking process: {e}")
            status['color_process'] = 'error'  # Update status in case of error

        # Update process status
        status['color_process'] = 'running'

        # Minimize sleep interval to keep the process active
        time.sleep(0.0001)  # Adjust the delay time as needed

def key_monitor(q_pressed, terminate_event, status):
    q_toggle = False
    while not terminate_event.is_set():
        if keyboard.is_pressed('q'):
            q_toggle = not q_toggle
            if q_toggle:
                q_pressed.set()
            else:
                q_pressed.clear()
            time.sleep(0.01)  # debounce delay

        # Minimize sleep interval to keep the process active
        time.sleep(0.0001)  # Adjust the delay time as needed

        # Update process status
        status['key_monitor'] = 'running'

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

    # Create shared status dictionary
    manager = multiprocessing.Manager()
    status = manager.dict()

    def place_dot(event):
        nonlocal dots
        if len(dots) < 4:
            key = ['d', 'f', 'j', 'k'][len(dots)]  # 'd', 'f', 'j', 'k'
            dot = Dot(canvas, event.x, event.y, key)
            dots.append(dot)
            # Start a process for checking color for this dot
            check_color_process = multiprocessing.Process(target=check_color, args=(event.x, event.y, key, q_pressed, terminate_event, status))
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
        check_color_process = multiprocessing.Process(target=check_color, args=(pos['x'], pos['y'], pos['key'], q_pressed, terminate_event, status))
        check_color_process.daemon = True
        check_color_process.start()

    # Start process for monitoring 'q' key press
    key_monitor_process = multiprocessing.Process(target=key_monitor, args=(q_pressed, terminate_event, status))
    key_monitor_process.daemon = True
    key_monitor_process.start()

    root.mainloop()

if __name__ == "__main__":
    main()

# chatgpt used for side notes, made by derovb:)
