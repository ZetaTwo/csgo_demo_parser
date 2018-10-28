# CS:GO Demo parser

This project aims to create a reusable library for parsing CS:GO demo files.
It uses a combination of [Kaitai](https://kaitai.io/) and [protobuf](https://developers.google.com/protocol-buffers/) to parse the CS:GO .dem demo files. The reason both are used is that CS:GO uses protobuf internally for some, but not all of their packets and then they wrap it all in a custom demo format. Kaitai is used to parse the outer binary format and then protobuf is used to parse the individual messages in the packets.

## Install

Run install.sh or perform the equivalent actions:

1. Install Kaitai compiler
2. Install Kaitai runtime for the language of your choice
3. Install protobuf compiler
4. Get the protobuf definitions from the [Valve demo parser](https://github.com/ValveSoftware/csgo-demoinfo.git).

## Usage

For example of how to use this, check the demo content dumper in parser.py
