#!/usr/bin/env python

#from protobuf_parser.cstrike15_usermessages_public_pb2 import
from protobuf_parser.netmessages_public_pb2 import *
from google.protobuf.internal.decoder import _DecodeVarint32

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

string_tables = []

def parse_string_updates(string_updates):
    print(repr(string_updates))
    pass # TODO

def handle_CreateStringTable(msg_create_string_table):
    parse_string_updates(msg_create_string_table.string_data)
    0/0
    pass # TODO: Parse StringTable entries

message_type_prefixes = {
    'svc': 'CSVCMsg',
    'net': 'CNETMsg',
}

special_parsers = {
    'svc_CreateStringTable': handle_CreateStringTable
}

def get_message_type(msg_type_name):
    prefix, name = msg_type_name.split('_', 2)
    msg_real_type_name = '%s_%s' % (message_type_prefixes[prefix], name)
    return getattr(sys.modules[__name__], msg_real_type_name)

def get_message_type_name(msg_type_id):
    if msg_type_id in NET_Messages.values():
        return NET_Messages.Name(msg_type_id)
    elif msg_type_id in SVC_Messages.values():
        return SVC_Messages.Name(msg_type_id)
    else:
        return False


def parse_messages(messages):
    for m in messages:
        msg_type_id = m.msg_type_id.value
        msg_type_name = get_message_type_name(msg_type_id)
        if not msg_type_name:
            print('[Frame::Packet::Message::???]')
            print('ID: %d' % msg_type_id)
        else:
            msg_type = get_message_type(msg_type_name)()
            msg_type.ParseFromString(m.body)
            print('[Frame::Packet::Message::%s]' % msg_type_name)
            print(msg_type)
            if msg_type_name in special_parsers:
                special_parsers[msg_type_name](msg_type)

def vector_to_str(vec):
    return '(%f,%f,%f)' % (vec.x, vec.y, vec.z)


def get_cmd_info(cmd_info):
    i = 1
    res = []
    for u in cmd_info.user:
        vectors = [vector_to_str(x) for x in [u.view_origin, u.view_angles, u.local_view_angles, u.view_origin2, u.view_angles2, u.local_view_angles2]]
        res.append('Player %d, [%d] %s,%s,%s,%s,%s,%s' % tuple([i, u.flags] + vectors))
        i += 1
    return '\n'.join(res)


def frame_packet(body):
    print('[Frame::Packet]')
    print(get_cmd_info(body.cmd_info))
    print('Seq in: %d' % body.seq_in)
    print('Seq out: %d' % body.seq_out)
    print('Length: %d' % body.length)
    parse_messages(body.messages.messages)

def frame_synctick(body):
    """Sync tick frame, no further content"""
    print('[Frame::Synctick]')

def frame_console_cmd(body):
    print('[Frame::ConsoleCmd]')
    # TODO

def frame_usercmd(body):
    print('[Frame::UserCmd]')
    # TODO

def frame_datatables(body):
    print('[Frame::DataTables]')
    # TODO

def frame_stringtables(body):
    print('[Frame::StringTables]')
    # TODO

def frame_stop(body):
    """Stop frame, no further content"""
    print('[Frame::Stop]')

frame_parsers = {
    Dem.FrameType.dem_signon: frame_packet,
    Dem.FrameType.dem_packet: frame_packet,
    Dem.FrameType.dem_synctick: frame_synctick,
    Dem.FrameType.dem_consolecmd: frame_console_cmd,
    Dem.FrameType.dem_usercmd: frame_usercmd,
    Dem.FrameType.dem_datatables: frame_datatables,
    Dem.FrameType.dem_stringtables: frame_stringtables,
    Dem.FrameType.dem_stop: frame_stop,
    Dem.FrameType.dem_customdata: False # TODO
}


for frame in g.frames:
    print('[Frame]')
    print('Frame type: %s' % frame.frame_type)
    print('Tick: %d' % frame.tick)
    print('Player slot: %d' % frame.player_slot)
    if frame.frame_type in frame_parsers:
        frame_parsers[frame.frame_type](frame.body)
    print('')