meta:
  id: string_table_update
  endian: le

params:
  # int entries
  # int nMaxEntries
  # int user_data_size
  # int user_data_size_bits
  # int user_data_fixed_size
  # bool bIsUserInfo
  - id: user_data_fixed_size
    type: bool
  - id: user_data_size_bits
    type: u4
  - id: user_data_size
    type: u4
  - id: max_entries
    type: u4
  
seq:
  - id: encode_using_dictionaries
    type: b1
  - id: entries
    #repeat: eos
    repeat: expr
    repeat-expr: 50 # Debug
    type:
      switch-on: encode_using_dictionaries
      cases:
        true: string_table_update_entries_dict
        false: string_table_update_entries(user_data_fixed_size, user_data_size_bits, user_data_size, max_entries)

instances:
  substring_bits:
    value: 5
  max_userdata_bits:
    value: 14 

types:
  string_table_update_entries:
    params:
      # int entries
      # int nMaxEntries
      # int user_data_size
      # int user_data_size_bits
      # int user_data_fixed_size
      # bool bIsUserInfo
      - id: user_data_fixed_size
        type: bool
      - id: user_data_size_bits
        type: u4
      - id: user_data_size
        type: u4
      - id: max_entries
        type: u4
    instances:
      nbytes:
        value: 'user_data_fixed_size ? user_data_size_bits : nbytes_data'
    seq:
      #- id: encode_using_dictionaries_repeated # TODO: Ugly workaround
      #  type: b1
      - id: same_index
        type: b1
      - id: new_index
        if: same_index == false
        type: 
          switch-on: max_entries
          cases:
            1: b1
            2: b2
            3: b3
            4: b4
            5: b5
            6: b6
            7: b7
            8: b8
            9: b9
            10: b10
            11: b11
            12: b12
            13: b13
            14: b14
            15: b15
            16: b16

        # demofiledump.cpp:633
      - id: flag1
        type: b1
      - id: substring_check
        type: b1
        if: flag1 == true
      - id: history_index
        type: b5
        if: flag1 == true and substring_check == true
      - id: bytestocopy
        type: b5 # substring_bits
        if: flag1 == true and substring_check == true
      - id: entry
        type: b8
        repeat: until
        repeat-until: _ == 0
        #encoding: ascii
        if: flag1 == true

        # demofiledump.cpp:664
      - id: flag2
        type: b1
      - id: nbytes_data
        type: b14 # max_userdata_bits
        if: flag2 == true and user_data_fixed_size == false
      - id: tempbuf
        #size: nbytes
        repeat: expr
        repeat-expr: 10
        #repeat-expr: nbytes
        type: b8
        if: flag2 == true

  string_table_update_entries_dict:
    doc: dummy
    seq:
     - id: data
       size-eos: true
