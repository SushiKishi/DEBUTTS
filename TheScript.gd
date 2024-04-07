extends Control

func _ready():
	pass # Replace with function body.


func _on_open_file_button_pressed():
	$OpenFileDialog.popup()
	

func _on_save_file_button_pressed():
	$SaveFileDialog.popup()	


func _on_open_file_dialog_file_selected(path):
	var p = $"Password Panel/PasswordBox".get_text()
	var f = FileAccess.open_encrypted_with_pass(path, FileAccess.READ, p)
	$TextEditor/TheData.set_text(f.get_as_text(false))
	f.close()


func _on_save_file_dialog_file_selected(path):
	
	var p = $"Password Panel/PasswordBox".get_text()
	var d = $TextEditor/TheData.text
	var f = FileAccess.open_encrypted_with_pass(path, FileAccess.WRITE, p)
	
	var saveJSON = JSON.parse_string(d)
	var saveData = JSON.stringify(saveJSON, "\t")
	
	f.store_string(saveData)
	f.close()
	
	

	




func _on_help_text_meta_clicked(meta):
	OS.shell_open(meta)
