# tag
A simple handy cli tool to manage your frequent files/scripts

### Installation
* Clone this repo on your local machine
* Open a terminal in root directory of the repo
* run `sudo ./install`

### Usage
    
    tag add [tag name] [file name]
    
To add tag to a file, cd to that particular directory, and run the above command to add a tag to that file

    tag list all
    
To print all the files in the database, and the tags associated with each

    tag list [tag name]
    
To print all the file with a given tag name

    tag recreate
    
To re-initialize the database.cd

### Uninstall
 run `sudo /usr/bin/.tag/uninstall`
