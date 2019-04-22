retCode, dirName = dialog.choose_directory(title='Choisir le dossier')
if retCode:
    dialog.info_dialog("Erreur")
else:
    keyboard.send_keys(dirName)
