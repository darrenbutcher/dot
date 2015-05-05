# Dot
# version 1.0
# 
# Create per-project virtual host Nginx config for .dev servers.  
# Initially intended to quickly create & spinup virtual hosts for Rails
# and Ember CLI projects. 
#
# SETUP:
# In order for dot to copy the per-project virtual host config
# Export nginx sites-available and sites-enabled paths in .zshrc  
# 
# export SITES_AVAILABLE_PATH="path/to/nginx/sites-available"
# export SITES_ENABLED_PATH="path/to/nginx/sites-enabled"

# Server extension
# Customize your server extension
# Default: .dev
server_extention="dev"

app_version="1.0"

# Custom plugins location
# Default uses the default zsh custom plugins location
# Customize the location if needed.
# Default: $HOME/.oh-my-zsh/custom/plugins
custom_plugins_location="$HOME/.oh-my-zsh/custom/plugins"

# Output colors
yellow='\033[1;033m'
red='\033[31m'
normal='\033[0m'
green='\033[32m'
blue='\033[34m'
magenta='\033[35m'

# Prompt colors
ok_color=$green
error_color=$red
warning_color=$yellow
normal_color=$normal
app_color=$magenta

# Plugin location
dot_plugin_location="$custom_plugins_location/dot"

# Experimental external template implementation
#dot_template=$dot_plugin_location/template.$server_extention

__create_config(){
  name=${PWD##*/}

  # Path to public & port
  public_path=$1
  app_port=$2

  # Config
  app_available_config=$3

  # Create virtual host config from template 
  printf "upstream $name {
    server 127.0.0.1:$app_port;
}

server {
    listen 80;
    server_name $name.$server_extention;
    root `pwd`/$public_path;

    try_files \$uri/index.html \$uri.html \$uri @app;

    location @app {
      proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
      proxy_set_header Host \$http_host;
      proxy_redirect off;

      proxy_pass http://$name;
    }
}
" >> $app_available_config
}

__init(){
  # App name 
  name=${PWD##*/}
  
  # Path to public & port
  public_path=$1
  app_port=$2

  # Set app config
  app_available_config=$SITES_AVAILABLE_PATH/$name.$server_extention

  # Create app config
  echo -e "dot: creating ${app_color}${name}${normal_color} nginx config."
  touch $app_available_config

  __create_config $public_path $app_port $app_available_config

  echo -e "dot: ${warning_color}NAME${normal_color} set."
  echo -e "dot: ${warning_color}PATH_TO_PUBLIC${normal_color} set."
  echo -e "dot: ${warning_color}APP_PORT${normal_color} set."
  
  # Include template file
  echo -e "dot: ${ok_color}config file complete.${normal_color}"

  # Link sites-available to sites-enabled
  ln -s $SITES_AVAILABLE_PATH/$name.$server_extention $SITES_ENABLED_PATH/$name.$server_extention
  echo -e "dot: ${app_color}${name}${normal_color} enabled."

  # Restart nginx
  echo -e "dot: ${warning_color}restarting nginx ...${normal_color}"
  echo -e "dot: ${ok_color}sudo nginx -s stop${normal_color}"
  sudo nginx -s stop
  echo -e "dot: ${ok_color}sudo nginx${normal_color}"
  sudo nginx
  echo -e "dot: ${ok_color}Awesome! ${app_color}${name}${normal_color} running & ready!"
}

# Remove config file
__dot_remove() {
  name=${PWD##*/}
  echo "dot: ${error_color}removing ${name} config.${normal_color}"
  rm $SITES_AVAILABLE_PATH/$name.$server_extention
  rm $SITES_ENABLED_PATH/$name.$server_extention
}

__dot_help(){
  printf "Example usage:                 
  
  [ Project root specific commands ]
    dot rails, r    - setup rails .$server_extention 
    dot ember, e    - setup ember .$server_extention
    dot list, ls    - list sites available
    dot show, sh    - show app config
    dot open, o     - open app config
    dot config, c   - open plugin config 
    dot remove, rm  - remove .$server_extention config 

  [ Global commands ]
    dot help, h     - show help 
    dot version, v  - show version
"
}

__dot_version () {
  echo -e "dot ${ok_color}version $app_version${normal_color}"
}

__dot_list () {
  ls $SITES_AVAILABLE_PATH
}

__dot_show () {
  less $1
}

__dot_open () {
  subl $1
}

__dot_config () {
  subl $dot_plugin_location/dot.plugin.zsh
}

__dot_not_found () {
  echo -e "dot: ${error_color}$1.$server_extention config not found.${normal_color}"
  echo -e "     possibly run ${warning_color}dot list${normal_color} show all sites-available."
}

__dot_command_not_found () {
    echo -e "dot: ${error_color}command not found.${normal_color}"
    echo -e "     run ${warning_color}dot help${normal_color} for list of available commands."
}

__config_locate () {
    cmd=$1
    app_name=$2
    app_location=$3
    
    if [[ -f $app_location ]]; then 
      cmd $app_location
    else
      __dot_not_found $app_name
    fi
} 

# Commands
dot_runner() {
  app_name=${PWD##*/}
  app_location=$SITES_AVAILABLE_PATH/$app_name.$server_extention
  
  if [[ $@ == "rails" || $@ == "r" ]]; 
    then
    # Set path to rails public directory
    public_path="public"
    
    # Set rails port
    # Uses the default rails port
    app_port=3000

    # Initialize config 
    __init $public_path $app_port $app_name
  elif [[ $@ == "ember" || $@ == "e" ]]; 
    then 
    # Set path to ember public directory
    public_path="dist"

    # Set rails port
    # Uses the default ember port
    app_port=4200

     # Initialize config 
    __init $public_path $app_port $app_name

  elif [[ $@ == "list" || $@ == "ls" ]]; 
    then 
    __dot_list

  elif [[ $@ == "show" || $@ == "sh" ]]; 
    then 
    __config_locate __dot_show $app_name $app_location

  elif [[ $@ == "open" || $@ == "o" ]]; 
    then 
    __config_locate __dot_open $app_name $app_location

  elif [[ $@ == "remove" || $@ == "rm" ]]; 
    then 
   __config_locate __dot_remove $app_name

  elif [[ $@ == "config" || $@ == "c" ]]; 
    then 
    __dot_config

  elif [[ $@ == "help" || $@ == "h" ]]; 
    then 
    __dot_help

  elif [[ $@ == "version" || $@ == "v" ]]; 
    then 
    __dot_version

  else
    __dot_command_not_found

  fi
}

alias dot='dot_runner'
