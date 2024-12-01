# scawm 

[home-manager](https://nix-community.github.io/home-manager/) module enabling you to define your shortcuts once and use them in any window manager of your liking. Ideal for people who like to procrastinate through fidgeting with their wm config instead of doing actual work but don't want to waste even more time configuring the same shortcuts for every window manager they want to try.

## usage 

flake.nix

```nix
inputs.scawm = {
    url = "github:omega-800/scawm";
    inputs.nixpkgs.follows = "nixpkgs";
};
```

configuration.nix

Modifiers must be separated with "+", keys with " "

```nix
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
