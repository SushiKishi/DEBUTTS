extends Control

#Panels
@export var ButtonBox: Panel
@export var Help: Panel
@export var Tutorial: Panel

#Data
@export var PasswordBoxData: LineEdit
@export var TextBox: TextEdit

#Dialog Boxes
@export var LoadFile: FileDialog
@export var SaveFile: FileDialog



func _ready():
	var version = "1.00" #dont forget to change it in project settings
	$"Main Window/Main Text Box/WindowLabel".set_text("[b]DEBUTTS v" + version + "[/b]")
	
	for button in ButtonBox.get_children():
		if button is Button:
			button.pressed.connect(_on_button_pressed.bind(button))


func _on_open_file_dialog_file_selected(path):
	var password = PasswordBoxData.get_text()
	var file = FileAccess.open_encrypted_with_pass(path, FileAccess.READ, password)
	
	if file: #returns true if the file wa sopened
		get("TextBox").set_text(file.get_as_text(false))
	else:
		OS.alert("Was unable to open the file; this is likely a password error, or the file itself is empty.", "E R R O R ! ! !")
		
	file.close()
	


func _on_save_file_dialog_file_selected(path):
	var password = PasswordBoxData.get_text()
	var data = TextBox.text
	var date = Time.get_datetime_string_from_system(false, false).replace(":","-").split("T")
	
	#separate path and file so you can create the path to put said file in
	var backupPath = OS.get_executable_path().get_base_dir()
	
	if !OS.has_feature("standalone"): #!standalone = not standalone = running from engine
			backupPath = backupPath.path_join("temp") ##Put into temp folder since this is running in GodotEngine folder
	
	backupPath = backupPath.path_join("backups").path_join(date[0]).path_join(date[1])
	var backupFile = path.get_file()
	
	if FileAccess.file_exists(path): #User is overwriting an existing file
		DirAccess.make_dir_recursive_absolute(backupPath) #make the folder
		DirAccess.copy_absolute(path, backupPath.path_join(backupFile)) #save the original
		
	#encrypt the data and save
	var file = FileAccess.open_encrypted_with_pass(path, FileAccess.WRITE, password)
	file.store_string(data)
	file.close()



func clicked_link(meta):
	OS.shell_open(meta)


func _on_button_pressed(buttonPressed):
	
	if buttonPressed.is_in_group("FileOpButtons"):
		if PasswordBoxData.get_text():
			get(buttonPressed.name).popup()
		else:
			OS.alert("You didn't enter a password.", "E R R O R ! ! !")
				
	
	if buttonPressed.is_in_group("ToggleWindowButtons"):
		get(buttonPressed.name).visible = !get(buttonPressed.name).visible
		
