{ ... }:

{
  # ── Swap & Memory Management (Gaming Optimized) ────────────────────────────

  # 1. High-Priority In-Memory Compressed Swap
  zramSwap = {
    enable = true;
    priority = 100;
    memoryPercent = 50;  # Allows up to 8GB of your RAM to be used for compression
    algorithm = "zstd";  # Zstandard offers the best compression-to-CPU-cost ratio
  };

  # 2. Low-Priority Physical Swapfile on NVMe Root (/)
  swapDevices = [
    {
      device = "/swapfile";
      size = 8192;      # 8 GB allocated on the NVMe
      priority = 10;    # Only used if zRAM is completely exhausted
    }
  ];

  # 3. Kernel Tuning for zRAM and Gaming Responsiveness
  boot.kernel.sysctl = {
    "vm.swappiness" = 150;
    "vm.watermark_boost_factor" = 0;
    "vm.watermark_scale_factor" = 125;
    "vm.page-cluster" = 0;
  };
}
