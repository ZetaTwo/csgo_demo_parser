#!/usr/bin/env python

from protobuf_parser import cstrike15_usermessages_public_pb2
from kaitai_parser.dem import Dem

g = Dem.from_file("samples/match730_003307379157293334783_1459413497_187.dem")

print('[Header]')
print('Magic: %s' % g.header.magic)
print('Demo version: %d' % g.header.demo_version)
print('Network version: %d' % g.header.network_version)
print('Server name: "%s"' % g.header.server_name)
print('Client name: "%s"' % g.header.client_name)
print('Map name: "%s"' % g.header.map_name)
print('Playback time: %f' % g.header.playback_time)
print('Ticks: %d' % g.header.ticks)
print('Tickrate: %d' % g.header.tickrate)
print('Frames: %d' % g.header.frames)
print('Sign-on length: %d' % g.header.signon_length)

