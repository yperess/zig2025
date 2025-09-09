# Getting started
1. Download the code:
   ```
   git clone --recurse-submodules https://github.com/yperess/zig2025.git
   cd zig2025
   ```

2. Set up the environment (On subsequent runs use `activate.sh`):
   ```
   source ./bootstrap.sh
   ```

3. Build the app

    * build for TDK robokit1:
      ```
      west build -p -b robokit1 app
      ```

    * Build for Raspberry Pi 2040:
      ```
      west build -p -b rpi_pico/rp2040 app
      ```
