# Dot

This custom `zsh plugin` was created in order to create per-project Nginx virtual host configs for `.dev` servers. Initially intended for me to quickly create & spinup virtual hosts for my Rails and Ember CLI projects.

## Setup
In order for dot to copy the per-project virtual host config,
export Nginx sites-available and sites-enabled paths in .zshrc  
 
```
export SITES_AVAILABLE_PATH="path/to/nginx/sites-available"
export SITES_ENABLED_PATH="path/to/nginx/sites-enabled"
```

## Customization
### Server Extension
The default server extension is `.dev` but this can be overwritten 
by setting `server_extention="custom-extension"` in the plugin config file.

### Custom Plugins Location
The default plugins location uses the default zsh custom plugins location
`$HOME/.oh-my-zsh/custom/plugins` but this cane be overwritten by setting
`custom_plugins_location="path/to/custom/plugins"` in the plugin config file.

## Basic Usage

### Project root specific commands
Run the following commands within your project root.

```
  dot rails, r    - setup rails .dev 
  dot ember, e    - setup ember .dev
  dot list, ls    - list sites available
  dot show, sh    - show app config
  dot open, o     - open app config
  dot config, c   - open plugin config 
  dot remove, rm  - remove .dev config 
```

### Global commands
```
  dot help, h     - show help 
  dot version, v  - show version
```

## License
Licensed under the [MIT License](http://nemo.mit-license.org/).
Free as beer!

##Credits
Darren Butcher: [@darrenbutcher](http://twitter.com/darrenbutcher)