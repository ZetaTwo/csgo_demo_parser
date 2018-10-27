#!/bin/sh

# Install protobug
sudo apt-get install protobuf-compiler libprotobuf-dev

# Download protobuf specs
mkdir -p protobuf_parser kaitai_parser
git clone https://github.com/ValveSoftware/csgo-demoinfo.git
cp csgo-demoinfo/demoinfogo/cstrike15_usermessages_public.proto protobuf
cp csgo-demoinfo/demoinfogo/netmessages_public.proto protobuf
rm -rf csgo-demoinfo

# Install kaitai
sudo apt-key adv --keyserver hkp://pool.sks-keyservers.net --recv 379CE192D401AB61
echo "deb https://dl.bintray.com/kaitai-io/debian jessie main" | sudo tee /etc/apt/sources.list.d/kaitai.list
sudo apt-get update
sudo apt-get install kaitai-struct-compiler
sudo -H pip install kaitaistruct
gem install kaitai-struct-visualizer
