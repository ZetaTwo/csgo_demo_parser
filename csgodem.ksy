meta:
  id: dem
  file-extension: dem
  endian: le
  imports:
    - /common/vlq_base128_le

seq:
  - id: header
    type: header
  - id: frames
    type: frame
    repeat: eos

types:
  header:
    seq:
      - id: magic
        contents: [HL2DEMO, 0]
      - id: demo_version
        type: s4
      - id: network_version
        type: s4
      - id: server_name
        type: strz
        size: 260
        encoding: ascii
      - id: client_name
        type: strz
        size: 260
        encoding: ascii
      - id: map_name
        type: strz
        size: 260
        encoding: ascii
      - id: game_directory
        type: strz
        size: 260
        encoding: ascii
      - id: playback_time
        type: f4
      - id: ticks
        type: s4
      - id: frames
        type: s4
      - id: signon_length
        type: s4
    instances:
      tickrate:
        value: ticks / playback_time
  frame:
    seq:
      - id: frame_type
        type: u1
        enum: frame_type
      - id: tick
        type: s4
      - id: player_slot
        type: u1
      - id: body
        type:
          switch-on: frame_type
          cases:
            'frame_type::dem_signon': frame_packet
            'frame_type::dem_packet': frame_packet
            'frame_type::dem_synctick': frame_synctick
            'frame_type::dem_consolecmd': frame_console_cmd
            'frame_type::dem_usercmd': frame_usercmd
            'frame_type::dem_datatables': frame_datatables
            'frame_type::dem_stop': frame_stop
            # TODO: 'frame_type::dem_customdata': u1
            'frame_type::dem_stringtables': frame_stringtables
    enums:
      frame_type:
        # it's a startup message, process as fast as possible
        1: dem_signon
        # it's a normal network packet that we stored off
        2: dem_packet
        # sync client clock to demo tick
        3: dem_synctick
        # console command
        4: dem_consolecmd
        # user input command
        5: dem_usercmd
        # network data tables
        6: dem_datatables
        # end of time.
        7: dem_stop
        # a blob of binary data understood by a callback function
        8: dem_customdata
        9: dem_stringtables

        # Last command
        #9: dem_lastcmd = dem_stringtables

    types:
      frame_synctick:
        doc: Sync tick
      frame_stop:
        doc: Stop tick
      frame_console_cmd:
        seq:
          - id: length
            type: s4
          - id: console_cmd
            size: length
      frame_datatables:
        seq:
          - id: length
            type: s4
          - id: data_table
            size: length
      frame_stringtables:
        seq:
          - id: length
            type: s4
          - id: string_table
            type: string_tables
            size: length

        types:
          string_tables:
            seq:
              - id: num_tables
                type: u1
              - id: tables
                type: string_table
                repeat: expr
                repeat-expr: num_tables

            types:
              string_table:
                seq:
                  - id: tablename
                    type: strz
                    encoding: ascii
                  - id: num_strings
                    type: s2
                  - id: strings
                    type: strz
                    encoding: ascii
                    repeat: expr
                    repeat-expr: num_strings
      frame_usercmd:
        seq:
          - id: length
            type: s4
          - id: user_cmd
            size: length
      frame_packet:
        seq:
          - id: cmd_info
            type: democmdinfo_t
          - id: seq_in
            type: s4
          - id: seq_out
            type: s4
          - id: length
            type: s4
          - id: messages
            type: message_list
            size: length

        types:
          democmdinfo_t:
            seq:
              - id: user
                type: split_t
                repeat: expr
                repeat-expr: max_splitscreen_clients

            instances:
              max_splitscreen_clients:
                value: 2

            types:
              split_t:
                seq:
                  # TODO: add derived flag values
                  - id: flags
                    type: s4
                  # Original origin/viewangles
                  - id: view_origin
                    type: vector
                  - id: view_angles
                    type: qangle
                  - id: local_view_angles
                    type: qangle
                  # Resampled origin/viewangles
                  - id: view_origin2
                    type: vector
                  - id: view_angles2
                    type: qangle
                  - id: local_view_angles2
                    type: qangle

                types:
                  vector:
                    seq:
                      - id: x
                        type: f4
                      - id: y
                        type: f4
                      - id: z
                        type: f4
                  qangle:
                    seq:
                      - id: x
                        type: f4
                      - id: y
                        type: f4
                      - id: z
                        type: f4

          message_list:
            seq:
              - id: messages
                type: message
                repeat: eos

            types:
              message:
                seq:
                  - id: msg_type_id
                    type: vlq_base128_le
                  - id: length
                    type: vlq_base128_le
                  - id: body
                    size: length.value