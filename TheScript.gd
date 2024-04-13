extends Control

#Panels (Lil' Windows)
@export var ButtonBox: Panel
@export var MainBox: Panel
@export var HelpBox: Panel
@export var CreditsBox: Panel

#Data
@export var PasswordBoxData: LineEdit
@export var TextBox: TextEdit


#Dialog Boxes
@export var LoadFile: FileDialog
@export var SaveFile: FileDialog



func _ready():
	
	var version = "1.00a" #dont forget to change it in project settings
	MainBox.get_node("WindowLabel").set_text("[b]DEBUTTS v" + version + "[/b]")
	
	var file = FileAccess.open("res://CREDITS.md", FileAccess.READ)
	CreditsBox.get_node("ReadmeBox").markdown_text = file.get_as_text(false)
	
	

	for button in ButtonBox.get_children():
		print(button.name)
		if button is Button:
			button.pressed.connect(_on_button_pressed.bind(button))
			
	
	for button in HelpBox.get_children():
		if button is Button:
			button.pressed.connect(_on_button_pressed.bind(button))		
			
	for button in CreditsBox.get_children():
		if button is Button:
			button.pressed.connect(_on_button_pressed.bind(button))		
			
			
func _on_open_file_dialog_file_selected(path):
	var password = PasswordBoxData.get_text()
	var file = FileAccess.open_encrypted_with_pass(path, FileAccess.READ, password)
	
	if file: #returns true if the file wa sopened
		get("TextBox").set_text(file.get_as_text(false))
	else:
		file = FileAccess.open(path, FileAccess.READ)
		if file.get_length() == 0:
			OS.alert("It seems like the file you selected is empty. Please try opening it in a standard text editor.", "E R R O R ! ! !")
		else:
			OS.alert("Error decrypting the file. This usually means you're using the wrong password.", "E R R O R ! ! !")		
	
	file.close()
	


func _on_save_file_dialog_file_selected(path):
	var password = PasswordBoxData.get_text()
	var data = TextBox.text
	var date = Time.get_datetime_string_from_system(false, false).replace(":","-").split("T")
	
	#separate path and file so you can create the path to put said file in
	var backupPath = OS.get_executable_path().get_base_dir()
	if OS.is_debug_build(): #!standalone = not standalone = running from engine
		backupPath = backupPath.path_join("temp") ##Put into temp folder since this is running in GodotEngine folder
		OS.alert("The app thing it's running as debug.", "This shouldn't happen!")
		
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
	print(buttonPressed.name + "\r")
	var scene = get_tree()
	
	#File Operations - load, save, etc
	if buttonPressed.is_in_group("FileOpButtons"):
		if PasswordBoxData.get_text():
			get(buttonPressed.name).popup()
		else:
			OS.alert("You didn't enter a password.", "E R R O R ! ! !")

	#Window toggles = close main, open help/credits	
	if buttonPressed.is_in_group("ToggleWindowButtons"):
		print("Toggle Window: " + buttonPressed.name)
		get(buttonPressed.name).visible = !get(buttonPressed.name).visible
		for w in scene.get_nodes_in_group("MainWindow"):
			w.visible = !w.visible

	#change what's in the credits box
	if buttonPressed.is_in_group("CreditsButton"):
		
		var fileName = buttonPressed.name.replace("[]",".").replace("-","/")
		var file = FileAccess.open("res://" + fileName, FileAccess.READ)
		
		#Workaround for the "machine-readable" godot-third-party file that
		#totally sucks when viewed as markdown
		if fileName.get_extension() == "md":
			#CreditsBox.get_node("ReadmeBox").text = ""
			CreditsBox.get_node("ReadmeBox").markdown_text = file.get_as_text(false)
		else:
			#CreditsBox.get_node("ReadmeBox").markdown_text = ""
			CreditsBox.get_node("ReadmeBox").text = file.get_as_text(false)
		
		
	#Buttons that open URLs
	if buttonPressed.is_in_group("URLButtons"):
		print("Toggle Window: " + buttonPressed.name)
		match buttonPressed.name:
			"Twitter":
				OS.shell_open("https://twitter.com/SushiKishi")
			"GitHub":
				OS.shell_open("https://github.com/SushiKishi/DEBUTTS/")
			"JSONlint":
				OS.shell_open("https://jsonlint.com")
