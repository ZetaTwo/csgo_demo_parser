#!/usr/bin/env python

from kaitaistruct import KaitaiStream
from io import BytesIO
#from protobuf_parser.cstrike15_usermessages_public_pb2 import
from protobuf_parser.netmessages_public_pb2 import *
import math

from kaitai_parser.dem import Dem
from kaitai_parser.frame import Frame
from kaitai_parser.string_table_update import StringTableUpdate

DEMO_PATH = "samples/match730_003307379157293334783_1459413497_187.dem"


def reverse_mask(b):
    return (b * 0x0202020202 & 0x010884422010) % 1023

assert(reverse_mask(0b10100011) == 0b11000101)

def flip_bytes(data):
    return ''.join([chr(reverse_mask(ord(x))) for x in data])

def print_demo_header(header):
    print('[Header]')
    print('Magic: %s' % header.magic)
    print('Demo version: %d' % header.demo_version)
    print('Network version: %d' % header.network_version)
    print('Server name: "%s"' % header.server_name)
    print('Client name: "%s"' % header.client_name)
    print('Map name: "%s"' % header.map_name)
    print('Playback time: %f' % header.playback_time)
    print('Ticks: %d' % header.ticks)
    print('Tickrate: %d' % header.tickrate)
    print('Frames: %d' % header.frames)
    print('Sign-on length: %d' % header.signon_length)

string_tables = []

def parse_string_updates(string_updates, user_data_fixed_size, user_data_size_bits, user_data_size, max_entries):
    flipped = flip_bytes(string_updates)
    entry_bits = int(math.log(max_entries,2))
    print('Entry bits: %d' % entry_bits)
    parsed_updates = StringTableUpdate(user_data_fixed_size, user_data_size_bits, user_data_size, entry_bits, KaitaiStream(BytesIO(flipped)))
    print('[StringTableUpdate]')
    print('Encoded using dictionaries: %s' % parsed_updates.encode_using_dictionaries)
    print('')

    if parsed_updates.encode_using_dictionaries:
        raise NotImplementedError("String table update dict not implemented")

    history = []
    last_index = -1

    for entry in parsed_updates.entries:
        entry_str = ""
        entry_index = last_index + 1
        print('Same index: %s' % entry.same_index)
        
        if not entry.same_index:
            entry_index = entry.new_index
        print('Index: %d' % entry_index)
        last_index = entry_index

        print('Flag 1: %s' % entry.flag1)
        if entry.flag1:
            print('Substring: %s' % entry.substring_check)
            if entry.substring_check:
                print('History index: %d' % entry.history_index)
                print('Bytes to copy: %d' % entry.bytestocopy)
                entry_str += history[entry.history_index][:entry.bytestocopy]
            entry_str += ''.join([chr(x) for x in entry.entry])
            print('Entry string: %s' % repr(flip_bytes(entry_str)))

        
        print('Flag 2: %s' % entry.flag2)
        if entry.flag2:
            print('User data fixed size: %s' % user_data_fixed_size)
            if user_data_fixed_size:
                print('User data size bits: %d' % user_data_size_bits)
            else:
                print('User data size bytes: %d' % entry.nbytes)
            print('String: %s' % entry.tempbuf)

        while len(history) > 31:
            history = history[1:]
        history.append(entry_str)
        print('')


def handle_CreateStringTable(msg_create_string_table):
    print(msg_create_string_table) # Debug print
    parse_string_updates(msg_create_string_table.string_data, msg_create_string_table.user_data_fixed_size, msg_create_string_table.user_data_size_bits, msg_create_string_table.user_data_size, msg_create_string_table.max_entries)

def handle_PacketEntities(msg_packet_entities):
    print(msg_packet_entities)
    raise NotImplementedError("PacketEntities not parsed")

message_type_prefixes = {
    'svc': 'CSVCMsg',
    'net': 'CNETMsg',
}

message_parsers = {
    'svc_CreateStringTable': handle_CreateStringTable,
    'svc_PacketEntities': handle_PacketEntities,
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


def dump_protobuf_pairs(body):
    for p in body.pairs:
        key = p.key.value
        field_tag = key >> 3
        wire_tag = key & 0b111
        print(field_tag, wire_tag, p.value)

def parse_messages(messages):
    for m in messages:
        msg_type_id = m.msg_type_id.value
        msg_type_name = get_message_type_name(msg_type_id)
        if not msg_type_name:
            print('[Frame::Packet::Message::???]')
            print('ID: %d' % msg_type_id)
            raise ValueError("Unknown message type: %d" % msg_type_id)
        else:
            msg_type = get_message_type(msg_type_name)()
            #dump_protobuf_pairs(m.body_parsed) # TESTING: Kaitai parsing instead of protobuf
            msg_type.ParseFromString(m.body)
            print('[Frame::Packet::Message::%s]' % msg_type_name)
            if msg_type_name in message_parsers:
                message_parsers[msg_type_name](msg_type)

def vector_to_str(vec):
    return '(%f,%f,%f)' % (vec.x, vec.y, vec.z)


def get_cmd_info(cmd_info):
    player_id = 1
    res = []
    for u in cmd_info.user:
        vectors = [vector_to_str(x) for x in [u.view_origin, u.view_angles, u.local_view_angles, u.view_origin2, u.view_angles2, u.local_view_angles2]]
        res.append('Player %d, [%d] %s,%s,%s,%s,%s,%s' % tuple([player_id, u.flags] + vectors))
        player_id += 1
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
    raise NotImplementedError("ConsoleCmd not parsed")
    # TODO

def frame_usercmd(body):
    print('[Frame::UserCmd]')
    raise NotImplementedError("UserCmd not parsed")
    # TODO

def frame_datatables(body):
    print('[Frame::DataTables]')
    raise NotImplementedError("DataTables not parsed")
    # TODO

def frame_stringtables(body):
    print('[Frame::StringTables]')
    raise NotImplementedError("StringTables not parsed")
    # TODO

def frame_stop(body):
    """Stop frame, no further content"""
    print('[Frame::Stop]')

def print_frame(frame):
    print('[Frame]')
    print('Frame type: %s' % frame.frame_type)
    print('Tick: %d' % frame.tick)
    print('Player slot: %d' % frame.player_slot)
    if frame.frame_type in frame_parsers:
        frame_parsers[frame.frame_type](frame.body)
    else:
        raise NotImplementedError("%s not parsed" % frame.frame_type)
    print('')


frame_parsers = {
    Frame.FrameType.dem_signon: frame_packet,
    Frame.FrameType.dem_packet: frame_packet,
    Frame.FrameType.dem_synctick: frame_synctick,
    Frame.FrameType.dem_consolecmd: frame_console_cmd,
    Frame.FrameType.dem_usercmd: frame_usercmd,
    Frame.FrameType.dem_datatables: frame_datatables,
    Frame.FrameType.dem_stringtables: frame_stringtables,
    Frame.FrameType.dem_stop: frame_stop,
    Frame.FrameType.dem_customdata: False # TODO
}


def main_streaming():
    with open(DEMO_PATH, 'rb') as f:
        stream = KaitaiStream(f)
        header = Dem.Header(stream)
        print_demo_header(header)
        i = 0
        while not stream.is_eof():
            if i == 2:
                break
            frame = Frame(stream)
            
            i += 1
            
            
            print_frame(frame)
            #if frame.frame_type in [Frame.FrameType.dem_signon, Frame.FrameType.dem_packet]:
            #parse_messages(frame.body.messages.messages)
            #    pass
            #else:
            #    print(frame.frame_type)

def main():
    # Non-streaming
    g = Dem.from_file(DEMO_PATH)
    print_demo_header(g.header)
    for frame in g.frames:
        print_frame(frame)

main_streaming()
