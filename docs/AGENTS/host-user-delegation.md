# Host-to-User Propagation

Bidirectional propagation (`den._.bidirectional`) has been removed from Den at #308.

If you used `den._.bidirectional` or relied on your host aspect directly having a `homeManager` class (or including aspects with a `homeManager` class) to configure all its users, follow these migration steps.

## The Problem with Bidirectional

Previously, a host could directly define a `homeManager` class or include aspects that did so, and `bidirectional` would ensure users received it. This often caused duplicate-definition errors because the host aspect would be re-evaluated within the user context pipeline, leading to redundant configurations.

## The Solution: Mutual Provider

The `den._.mutual-provider` battery is the new standard. It enforces a strict separation: host aspects only define host-level configuration, while configuration meant for users must be explicitly delegated using `provides.to-users`.

### Before (Deprecated)

```nix
den.hosts.x86_64-linux.igloo.users.tux = {};

den.ctx.user.includes = [ den._.bidirectional ];

den.aspects.igloo = {
   nixos = ...; # host specific stuff
   homeManager = ...; # things provided to all users
   includes = [
     den.aspects.gui # If 'gui' had a homeManager class, it caused duplicate errors
     ({ host }: ...) # functions for host-only context
     ({ host, user }: ...) # functions for user context 
   ];
};
```

### After (Recommended)

```nix
den.hosts.x86_64-linux.igloo.users.tux = {};

den.ctx.user.includes = [ den._.mutual-provider ];

den.aspects.igloo = {
   nixos = ...; # host specific stuff
   # homeManager classes are NOT available here, only at the user context.
   includes = [
     # Only include aspects that STRICTLY lack homeManager/user classes
     ({ host }: ...) # functions for host-only context 
     # exactly({ host, user }) is not reachable here     
   ];

   # Explicitly provide configuration to all users of this host
   provides.to-users = {
     nixos = ...; # User contexts can provide OS classes back to the host!
     homeManager = ...; # Things provided to all users using home classes
     includes = [
       den.aspects.gui # Safe to include aspects with homeManager here
       ({ host, user }: ...) # functions for user context
       # exactly({ host }) is not reachable here
     ];
   };
};
```

### Key Takeaways

1. **No `homeManager` in Host Context:** A host aspect (`den.aspects.<hostname>`) cannot directly define a `homeManager` attribute.
2. **Watch your `includes`:** If you have an aspect (e.g., `gui`, `gaming`) that defines *both* `nixos` and `homeManager` configurations, you **must** add it to the host's `provides.to-users.includes` array instead of the host's top-level `includes`. 
3. **Upward OS Propagation:** You don't lose OS configuration by moving aspects into `provides.to-users`. Any `nixos` configuration defined within those user-delegated aspects will still safely propagate back "up" to the host.