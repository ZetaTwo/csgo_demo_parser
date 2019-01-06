meta:
  id: message
  endian: le
  imports:
    - /common/vlq_base128_le
#    - /serialization/google_protobuf

seq:
  - id: msg_type_id
    type: vlq_base128_le
  - id: length
    type: vlq_base128_le
  - id: body
    size: length.value
#    type:
#      switch-on: msg_type_id_value
#      cases:
#        'message_type::svc_server_info': google_protobuf

instances:
  msg_type_id_value:
    value: msg_type_id.value
    enum: message_type

enums:
  message_type:
    0:  net_nop # NOP
    1:  net_disconnect # disconnect, last message in connection
    2:  net_file # file transmission message request/deny
    4:  net_tick # s->c world tick, c->s ack world tick
    5:  net_string_cmd  # a string command
    6:  net_set_con_var  # sends one/multiple convar/userinfo settings
    7:  net_signon_state  # signals or acks current signon state
    8:  svc_server_info # first message from server about game; map etc
    9:  svc_send_table # sends a sendtable description for a game class
    10: svc_class_info # Info about classes (first byte is a CLASSINFO_ define).
    11: svc_set_pause # tells client if server paused or unpaused
    12: svc_create_string_table # inits shared string tables
    13: svc_update_string_table # updates a string table
    14: svc_voice_init # inits used voice codecs & quality
    15: svc_voice_data # Voicestream data from the server
    16: svc_print # print text to console
    17: svc_sounds # starts playing sound
    18: svc_set_view # sets entity as point of view
    19: svc_fix_angle # sets/corrects players viewangle
    20: svc_crosshair_angle # adjusts crosshair in auto aim mode to lock on traget
    21: svc_bsp_decal # add a static decal to the world BSP
    23: svc_user_message # a game specific message 
    25: svc_game_event # global game event fired
    26: svc_packet_entities # non-delta compressed entities
    27: svc_temp_entities # non-reliable event object
    28: svc_prefetch # only sound indices for now
    29: svc_menu # display a menu from a plugin
    30: svc_game_event_list # list of known games events and fields
    31: svc_get_cvar_value # Server wants to know the value of a cvar on the client	

types:
  svc_server_info:
    doc: svc_server_info
