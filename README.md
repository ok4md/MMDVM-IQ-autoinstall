This Bash script automates the complete installation, compilation, and configuration process
required to run an MMDVM hotspot using an ADALM-Pluto SDR on Debian-based Linux distributions
(including Raspberry Pi OS and Armbian).

What this script does:

 Installs System Dependencies: Updates package repositories and installs all required
 development tools, compiler components (g++, cmake), and libraries
 (libiio, libad9361, nlohmann-json, alsa).
 
 Configures MQTT Broker (Mosquitto): 
 Installs Mosquitto and configures it to allow anonymous local connections,
 ensuring MMDVM-IQ can successfully publish data without "Connection refused" errors.

 Sets Up UDEV Rules: Creates specific USB rules (53-adi-plutosdr-usb.rules) for the ADALM-Pluto SDR,
 allowing the MMDVM process to access the hardware without requiring root privileges.

 Builds SoapyPlutoSDR Driver: Clones and compiles the SoapyPlutoSDR module from source,
 enabling SoapySDRUtil to detect and control the Pluto SDR.

 Compiles MMDVM Software Stack: Automatically clones, cleans, and compiles the latest versions of
 MMDVM-IQ, MMDVM-Host, and DMRGateway directly from their respective GitHub repositories.
 It utilizes multi-core compilation (make -j$(nproc)) to maximize speed.

How to use:

1. Download or copy the script to your Debian system (e.g., as install_mmdvm-iq.sh).
   Make the script executable:    chmod +x install_mmdvm.sh

2. Run the script:    ./install_mmdvm.sh

Once completed, all binaries and source codes will be available in the ~/mmdvm_build directory,
ready for your specific .ini configuration files. Enjoy!
