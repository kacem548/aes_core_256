## AES-256 VHDL Core (ISE 14.7 Compatible)

Project structure:

- `src/aes_pkg.vhd`: Types, S-Box, Inv S-Box, Rcon, GF(2^8) helpers
- `src/add_round_key.vhd`: AddRoundKey
- `src/subbytes.vhd`, `src/inv_subbytes.vhd`
- `src/shiftrows.vhd`, `src/inv_shiftrows.vhd`
- `src/mixcolumns.vhd`, `src/inv_mixcolumns.vhd`
- `src/key_expand_aes256.vhd`: AES-256 key schedule -> 15 round keys
- `src/aes_round_enc.vhd`, `src/aes_round_dec.vhd`: round primitives
- `src/aes256_core.vhd`: Iterative top-level core with FSM
- `tb/tb_aes256_core.vhd`: Testbench with NIST AES-256 vectors

### Build & Simulate (Xilinx ISE 14.7)

1. Create a new ISE project, set family to Virtex-5 (e.g. ML501: XC5VLX50T), VHDL.
2. Add all VHDL files from `src/` to the project, mark `tb/tb_aes256_core.vhd` as top for simulation.
3. Ensure `aes_pkg.vhd` is compiled before other design files.
4. Run behavioral simulation. The testbench prints "All tests passed" when successful.

### Interface

Top-level `aes256_core` ports:

- `clk`, `rst`: clock and synchronous reset
- `start`: pulse high to begin operation
- `enc_n`: '1' encrypt, '0' decrypt
- `key`: 256-bit key
- `data_in`: 128-bit plaintext or ciphertext
- `data_out`: 128-bit result after `ready`
- `ready`: high for one cycle when output is valid

