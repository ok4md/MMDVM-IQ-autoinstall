#!/bin/bash
#Martin OK4MD
# Ukončit skript, pokud jakýkoliv příkaz selže
set -e

echo "=================================================================="
echo " Spouštím automatickou instalaci MMDVM + PlutoSDR pro Debian"
echo "=================================================================="

# 1. Aktualizace systému a instalace základních závislostí
echo -e "\n[1/7] Aktualizace repozitářů a instalace systémových balíčků..."
sudo apt-get update
sudo apt-get install -y git cmake g++ build-essential wget curl \
    libsoapysdr-dev soapysdr-tools libiio-dev libiio-utils libad9361-dev \
    libmosquitto-dev mosquitto mosquitto-clients nlohmann-json3-dev \
    libasound2-dev

# 2. Nastavení MQTT (Mosquitto v2+) pro anonymní lokální přístup
echo -e "\n[2/7] Konfigurace MQTT brokeru (Mosquitto)..."
sudo tee /etc/mosquitto/conf.d/local.conf > /dev/null <<EOF
listener 1883
allow_anonymous true
EOF
sudo systemctl restart mosquitto

# 3. Nastavení UDEV pravidel pro PlutoSDR
echo -e "\n[3/7] Nastavení UDEV pravidel pro USB přístup k PlutoSDR..."
sudo tee /etc/udev/rules.d/53-adi-plutosdr-usb.rules > /dev/null <<EOF
SUBSYSTEM=="usb", ATTRS{idVendor}=="0456", ATTRS{idProduct}=="b673", MODE="0666", GROUP="plugdev"
EOF
sudo udevadm control --reload-rules
sudo udevadm trigger

# Vytvoření pracovního adresáře pro kompilaci v domovské složce
COMP_DIR="$HOME/mmdvm_build"
mkdir -p "$COMP_DIR"
cd "$COMP_DIR"

# 4. Stažení a kompilace SoapyPlutoSDR driveru
echo -e "\n[4/7] Stahování a kompilace driveru SoapyPlutoSDR..."
if [ ! -d "SoapyPlutoSDR" ]; then
    git clone https://github.com/pothosware/SoapyPlutoSDR
fi
cd SoapyPlutoSDR
mkdir -p build && cd build
cmake ..
make -j$(nproc)
sudo make install
sudo ldconfig
cd "$COMP_DIR"

# 5. Stažení a kompilace MMDVM-IQ
echo -e "\n[5/7] Stahování a kompilace MMDVM-IQ..."
if [ ! -d "mmdvm-iq" ]; then
    # Poznámka: Změňte URL na oficiální repozitář, pokud používáte jiný fork
    git clone https://github.com/g4klx/MMDVM-IQ
fi
cd MMDVM-IQ
# Vyčištění případné staré kompilace a nový build
make clean || true
make -j$(nproc)
cd "$COMP_DIR"

# 6. Stažení a kompilace MMDVMHost
echo -e "\n[6/7] Stahování a kompilace MMDVMHost..."
if [ ! -d "MMDVMHost" ]; then
    git clone https://github.com/g4klx/MMDVM-Host
fi
cd MMDVM-Host
make clean || true
make -j$(nproc)
cd "$COMP_DIR"

# 7. Stažení a kompilace DMRGateway
echo -e "\n[7/7] Stahování a kompilace DMRGateway..."
if [ ! -d "DMRGateway" ]; then
    git clone https://github.com/g4klx/DMRGateway
fi
cd DMRGateway
make clean || true
make -j$(nproc)

echo "=================================================================="
echo " INSTALACE DOKONČENA ÚSPĚŠNĚ!"
echo "=================================================================="
echo "Všechny zdrojové kódy a binárky najdete v: $COMP_DIR"
echo "Nezapomeňte upravit .ini soubory pro MMDVM-IQ, MMDVMHost a DMRGateway."
echo "=================================================================="
