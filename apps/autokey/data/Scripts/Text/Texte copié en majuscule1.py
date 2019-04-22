import time
time.sleep(0.25)
contents = clipboard.get_clipboard()
uppercase_contents = contents.upper()
keyboard.send_keys(uppercase_contents)
clipboard.fill_clipboard(uppercase_contents)