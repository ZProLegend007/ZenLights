import os
import numpy as np
import pyaudio
import time
import threading
import ctypes

# Define a no-op error handler for ALSA
def py_error_handler(filename, line, function, err, fmt):
    pass

# Set the error handler
c_error_handler = ctypes.CFUNCTYPE(None, ctypes.c_char_p, ctypes.c_int, ctypes.c_char_p, ctypes.c_int, ctypes.c_char_p)
error_handler = c_error_handler(py_error_handler)
alsa = ctypes.CDLL('libasound.so')
alsa.snd_lib_error_set_handler(error_handler)

# Constants for bass frequency range
BASS_MIN_FREQ = 20
BASS_MAX_FREQ = 150
SAMPLE_RATE = 44100
CHUNK = 2048  # Reduced from 1024 to 512

# Initial settings
last_brightness = 0
fade_duration = 0.15

# Thread control for fading
fade_event = threading.Event()
fade_thread = None
fade_in_progress = False

# Rate limiting control
last_brightness_change_time = 0
min_time_between_changes = 0.0

# Presets
presets = {
    1: {"name": "Low Sensitivity", "fixed_min_bass_amplitude": 0, "max_bass_amplitude": 30},
    2: {"name": "Normal", "fixed_min_bass_amplitude": 5, "max_bass_amplitude": 40},
    3: {"name": "High Sensitivity", "fixed_min_bass_amplitude": 10, "max_bass_amplitude": 50}
}

# Ask for preset
def select_preset():
    print("Select a preset:")
    for key, value in presets.items():
        print(f"{key}: {value['name']}")
    choice = int(input("Enter the number of the preset: "))
    return presets.get(choice, presets[2])

# High-pass filter function
def high_pass_filter(signal, cutoff_freq=20, sample_rate=SAMPLE_RATE):
    RC = 1.0 / (2 * np.pi * cutoff_freq)
    dt = 1.0 / sample_rate
    alpha = dt / (RC + dt)
    
    filtered_signal = np.zeros_like(signal, dtype=np.float32)
    filtered_signal[0] = signal[0]
    
    for i in range(1, len(signal)):
        filtered_signal[i] = alpha * (filtered_signal[i-1] + signal[i] - signal[i-1])
    
    return filtered_signal

def set_brightness(brightness):
    os.system(f"brightnessctl --device='asus::kbd_backlight' set {brightness} > /dev/null 2>&1")

def fade_out():
    global fade_thread, fade_event, fade_in_progress

    if fade_in_progress:
        fade_event.set()
        fade_thread.join()

    fade_event.clear()
    fade_in_progress = True

    def fade():
        global last_brightness
        start_brightness = last_brightness
        fade_steps = 3
        step_duration = fade_duration / fade_steps

        for step in range(fade_steps + 1):
            if fade_event.is_set():
                return
            
            brightness = int(start_brightness * (1 - step / fade_steps))
            set_brightness(brightness)
            time.sleep(step_duration)

        if not fade_event.is_set():
            set_brightness(0)
            last_brightness = 0
        
        fade_in_progress = False

    fade_thread = threading.Thread(target=fade)
    fade_thread.start()

def adjust_backlight(intensity, preset):
    global last_brightness, last_brightness_change_time

    current_time = time.time()
    time_since_last_change = current_time - last_brightness_change_time

    if time_since_last_change < min_time_between_changes:
        return

    max_bass_amplitude = preset["max_bass_amplitude"]
    threshold_3 = 0.50 * max_bass_amplitude
    threshold_2 = 0.30 * max_bass_amplitude
    threshold_1 = 0.20 * max_bass_amplitude
    threshold_0 = 0.10 * max_bass_amplitude

    if intensity >= threshold_3:
        brightness = 3
    elif intensity >= threshold_2:
        brightness = 2
    elif intensity >= threshold_1:
        brightness = 1
    else:
        brightness = 0

    if brightness == 3 and (fade_in_progress or last_brightness != 3):
        if fade_in_progress:
            fade_event.set()
            fade_thread.join()
        set_brightness(brightness)
        last_brightness = brightness
        last_brightness_change_time = current_time
        fade_out()
    elif not fade_in_progress and brightness != last_brightness:
        set_brightness(brightness)
        last_brightness = brightness
        last_brightness_change_time = current_time
        if brightness > 0:
            fade_out()

def process_audio(indata, preset):
    audio_data = np.frombuffer(indata, dtype=np.int16).astype(np.float32)
    filtered_data = high_pass_filter(audio_data)
    window = np.hanning(len(filtered_data))
    normalized_data = filtered_data * window
    spectrum = np.fft.rfft(normalized_data)
    freqs = np.fft.rfftfreq(len(normalized_data), d=1./SAMPLE_RATE)
    bass_mask = (freqs >= BASS_MIN_FREQ) & (freqs <= BASS_MAX_FREQ)
    bass_frequencies = np.abs(spectrum[bass_mask])

    if bass_frequencies.size > 0:
        bass_amplitude = np.mean(bass_frequencies)
    else:
        bass_amplitude = 0

    if bass_amplitude < preset["fixed_min_bass_amplitude"]:
        bass_amplitude = 0

    adjust_backlight(bass_amplitude, preset)

    # Visualization
    os.system('clear')
    bar_length = int((bass_amplitude / preset["max_bass_amplitude"]) * 50)
    print("Bass Amplitude: [" + "#" * bar_length + " " * (50 - bar_length) + "]")

def listen_internal(preset):
    p = pyaudio.PyAudio()
    stream = p.open(format=pyaudio.paInt16,
                    channels=1,
                    rate=SAMPLE_RATE,
                    input=True,
                    frames_per_buffer=CHUNK)

    try:
        while True:
            data = stream.read(CHUNK, exception_on_overflow=False)
            process_audio(data, preset)
    except KeyboardInterrupt:
        stream.stop_stream()
        stream.close()
        p.terminate()

def main():
    preset = select_preset()
    os.system('clear')
    listen_internal(preset)

if __name__ == "__main__":
    main()
