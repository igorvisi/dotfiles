import time
time.sleep(0.25)
contents = clipboard.get_clipboard()
lower_contents = contents.lower()
keyboard.send_keys(lower_contents)
clipboard.fill_clipboard(lower_contents)