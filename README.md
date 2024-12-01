# scawm 

This is a [home-manager](https://nix-community.github.io/home-manager/) module enabling you to define your shortcuts once and use them in any window manager of your liking. Ideal for people who like to procrastinate through fidgeting with their wm config instead of doing actual work but don't want to waste even more time configuring the same shortcuts for every window manager they want to try.

## usage 

```nix
# flake.nix

inputs.scawm = {
    url = "github:omega-800/scawm";
    inputs.nixpkgs.follows = "nixpkgs";
};
```


Modifiers must be separated with "+", keys with " "

```nix
# configuration.nix

imports = [ inputs.scawm.homeManagerModules.scawm ];

config.scawm = {
    enable = true;
    modifier = "Super";
    bindings = {
        "Ctrl+Shift s" = "flameshot full";
        "Super r" = {
            name = "Run";
            switch = {
                "s" = "spotify";
                "f" = "firefox";
            };
        };
    }; 
};
```

example config can be found in ./test
