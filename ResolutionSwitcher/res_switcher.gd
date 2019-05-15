tool # Always declare as Tool, if it's meant to run in the editor.
extends EditorPlugin

var path = "res://addons/ResolutionSwitcher/list.txt"

var toolbar_button = null
var main_popup = null
var config_file = null
var res_data = null
var custom_window = null

func get_name(): 
	return "Resolution Switcher"


func _init():
	pass
	

func _enter_tree():	
	toolbar_button = MenuButton.new()
	toolbar_button.set_text("Switch Resolution")
	main_popup = toolbar_button.get_popup()
	
	reload()
	
	add_control_to_container(CONTAINER_CANVAS_EDITOR_MENU,toolbar_button)
	main_popup.connect("id_pressed",self,"switched")
	custom_window = preload("custom_res_popup.res").instance()

	
func reload():	
	config_file = ConfigFile.new()
	config_file.load(path)
	
	res_data = {}
	main_popup.clear()
	for section in config_file.get_sections():
		for label in config_file.get_section_keys(section):
			var wh = config_file.get_value(section,label).split("x")
			var w = wh[0]
			var h = wh[1]
			var t = label + "    (" + w + "x" + h +")"
			res_data[t] = {"label":label,"width":w,"height":h}
			main_popup.add_item(t)
		main_popup.add_separator()
		
	main_popup.add_item("Add Custom Size")
	

func switched(id):
	var key = main_popup.get_item_text(id)
	
	if key == "Add Custom Size":
		if custom_window.get_parent()==null:
			add_child(custom_window)
		custom_window.show()
		custom_window.popup_centered()
		var checkSignalObject = custom_window.get_node("vbox/hbox3/addButton") as Object
		if checkSignalObject.get_signal_connection_list("pressed").size() == 0:
			custom_window.get_node("vbox/hbox3/addButton").connect("pressed",self,"_on_add_new",[],CONNECT_ONESHOT)
		custom_window.get_node("vbox/hbox4/category").clear()
		for section in config_file.get_sections():
			custom_window.get_node("vbox/hbox4/category").add_item(section)
	else:
		var w = res_data[key]["width"]
		var h = res_data[key]["height"]
		toolbar_button.set_text(key)
		ProjectSettings.set_setting("display/window/size/test_height", h)
		ProjectSettings.set_setting("display/window/size/test_width", w)
		ProjectSettings.set_initial_value("display/window/size/test_width", w)
		ProjectSettings.set_initial_value("display/window/size/test_height", h)
		ProjectSettings.save()

func _on_add_new():
	var category = custom_window.get_node("vbox/hbox4/category").get_item_text(custom_window.get_node("vbox/hbox4/category").get_selected())
	var label = custom_window.get_node("vbox/hbox1/labelText").get_text()
	var width = int(custom_window.get_node("vbox/hbox2/widthText").get_text())
	var height = int(custom_window.get_node("vbox/hbox2/heightText").get_text())
	if height==0 or width==0 or  label=="":
		var c = AcceptDialog.new()
		add_child(c)
		c.set_title("Error")
		c.set_text("Resolution not added because of incomplete\n details")
		c.popup_centered(Vector2(300,100))
		c.set_exclusive(true)
		c.show()
	else:
		config_file.set_value(category,label,str(width)+"x"+str(height))
		config_file.save(path)
		reload()
	custom_window.hide()

func _exit_tree():
	main_popup.clear()
	main_popup = null
	res_data.clear()
	toolbar_button.free()
	toolbar_button=null
	config_file = null
	custom_window.free()
	custom_window = null
