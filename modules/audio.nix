{ ... }:

{
  security.rtkit.enable = true; # Allows PipeWire to acquire real-time priority

  services.pipewire = {
    enable = true;
    alsa.enable        = true;
    alsa.support32Bit  = true; # Required for 32-bit Steam games
    pulse.enable       = true; # PulseAudio compatibility layer
  };
}
