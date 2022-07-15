# butler-gui
A graphical user interface for the butler tool from itch.io

Simply scan your .builds folder with the "Auto Queue" feature to detect which channel to update! Customize the app with your own themes (Install themes in... Windows: %APPDATA%\Godot\app_userdata\Butler GUI\themes macOS: ~/Library/Application Support/Godot/app_userdata/Butler GUI/themes Linux: ~/.local/share/godot/app_userdata/Butler GUI/themes).

# How to: Setup
At first launch, you might notice "NULL" being printed out at the Output panel. This is because you first have to give butler-gui some information to work with. Click on the "settings" button and head over to the "user" tab, and add some Information, like your itch io usernames or games. (Input values must be seperated with commas, followed by a space. Like this:"my-game, also-my-game"). Don't forget to **click "save"** before closing the settings popup. 

# How to: Auto Queue
First, you need to select a folder to scan for subfolders. Builds *have to* be seperated into their own folders, and must be named after your channel's platform.
Then, you pick a username and the game to update.
You will also have to select a "folder structure".
This tells butler-gui how to fill in the details when it finds your folders.
  - platform-type (example: "windows-beta, linux-stable")
  - platform (example: "ios, android")

If you picked "platform" you will also be prompted to select a build-type.

After all of this, you can finally hit "scan" and butler-gui will show you a preview of commands it will use to push your changes.

Finally, click the "push" button to let butler-gui execute the previewed commands. 

# How to install a Theme
Drop your .tres files in one of the following folders:
  Windows: %APPDATA%\Godot\app_userdata\Butler GUI\themes
  macOS: ~/Library/Application Support/Godot/app_userdata/Butler GUI/themes
  Linux: ~/.local/share/godot/app_userdata/Butler GUI/themes
  
Then, open butler-gui, go to settings/style/theme and select your theme in the button next to the "theme:" label.
