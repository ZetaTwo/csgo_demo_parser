# CS:GO Demo parser

This project aims to create a reusable library for parsing CS:GO demo files.
It uses a combination of [Kaitai](https://kaitai.io/) and [protobuf](https://developers.google.com/protocol-buffers/) to parse the CS:GO .dem demo files. The reason both are used is that CS:GO uses protobuf internally for some, but not all of their packets and then they wrap it all in a custom demo format. Kaitai is used to parse the outer binary format and then protobuf is used to parse the individual messages in the packets.

Some basic info on the demo format: https://developer.valvesoftware.com/wiki/DEM_Format

## Project status

This library is not fully functional yet. Initially the goal was to write a parser based purely on Kaitai Struct and Protobuf to make it portable.
It turned out, due to how the demo file format is structured, that this is not really currently feasible.

Instead, the idea is to create a parser and tool in one language, currently python, to convert the demos into a different, more consistently structured format.
This format will possibly be based on protobuf. Then that file fromat will be much to parse in any protobuf supported language of choice.

Currently, I'm still implementing parsing for all frames and messages.

## Install

Run install.sh or perform the equivalent actions:

1. Install Kaitai compiler
2. Install Kaitai runtime for the language of your choice
3. Get the Kaitai format gallery: https://github.com/kaitai-io/kaitai_struct_formats.git
4. Install protobuf compiler
5. ~~Get the protobuf definitions from the [Valve demo parser](https://github.com/ValveSoftware/csgo-demoinfo.git).~~
5. Get the protobuf definitions from the Linux fork of the [Valve demo parser](https://github.com/kaimallea/demoinfogo-linux).

## Build

Run compile.sh or perform the equivalent actions:

1. Compile the Valve protobuf specifications to parsers in your desired language
2. Compile the csgodem.ksy kaitai specifications into parsers in your desired language

## Usage

For example of how to use this, check the demo content dumper in parser.py
Basically, you parse the demo file with the Kaitai parser and then use the protobuf varint decoder to iterate over (type,size) pairs of frame.body.inner_packet and then parse those chunks with the protobuf parsers.

## License

This is Licensed under MIT but I would be very happy if you told me about any project you use this in.
