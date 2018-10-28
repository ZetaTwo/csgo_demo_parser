#!/bin/sh
protoc -I=protobuf --python_out=protobuf_parser protobuf/*.proto
ksc -I kaitai_struct_formats --target=python -d=kaitai_parser csgodem.ksy

# Visualize:
# ksv samples/match730_003307379157293334783_1459413497_187.dem csgodem.ksy
