#!/bin/sh
protoc -I=protobuf --python_out=protobuf_parser protobuf/*.proto
ksc -I ~/tools/kaitai_struct_formats --target=python -d=kaitai_parser csgodem.ksy
ksc -I ~/tools/kaitai_struct_formats --target=python -d=kaitai_parser csgodem_string_update.ksy

# Work-around for bit-alignment in Kaitai until https://github.com/kaitai-io/kaitai_struct/issues/12 is implemented
sed -i 's/self._io.align_to_byte()/#self._io.align_to_byte()/g' kaitai_parser/string_table_update.py

# Work-around for mixed-endianess in Kaitai until https://github.com/kaitai-io/kaitai_struct/issues/76 is implemented
sed -i 's/self.nbytes_data = self._io.read_bits_int(14)/self.nbytes_data = int(format(self._io.read_bits_int(14), "014b")[::-1], 2)/g' kaitai_parser/string_table_update.py
sed -i 's/self.history_index = self._io.read_bits_int(5)/self.history_index = int(format(self._io.read_bits_int(5), "05b")[::-1], 2)/g' kaitai_parser/string_table_update.py
sed -i 's/self.bytestocopy = self._io.read_bits_int(5)/self.bytestocopy = int(format(self._io.read_bits_int(5), "05b")[::-1], 2)/g' kaitai_parser/string_table_update.py

# Work-around for dynamic variable size in Kaitai until ???
sed -i 's/self.tempbuf2 = self._io.read_bits_int(1337)/self.tempbuf2 = self._io.read_bits_int(self.user_data_size_bits)/g' kaitai_parser/string_table_update.py

# Visualize:
# ksv samples/match730_003307379157293334783_1459413497_187.dem csgodem.ksy
