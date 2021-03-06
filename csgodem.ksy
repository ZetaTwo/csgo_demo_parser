meta:
  id: dem
  file-extension: dem
  endian: le
  imports:
    - csgodem_frames

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
