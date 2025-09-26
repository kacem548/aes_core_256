# AES-256 VHDL (ISE 14.7 compatible)

Modular AES-256 implementation in VHDL for Xilinx ISE 14.7 and Virtex ML501.

## Structure
- `src/aes_pkg.vhd`: S-Boxes, Inv S-Boxes, Rcon, GF(2^8) utils, transforms, key expansion
- `src/aes_subbytes.vhd`, `src/aes_inv_subbytes.vhd`
- `src/aes_shiftrows.vhd`, `src/aes_inv_shiftrows.vhd`
- `src/aes_mixcolumns.vhd`, `src/aes_inv_mixcolumns.vhd`
- `src/aes_addroundkey.vhd`
- `src/aes_key_schedule_256.vhd`
- `src/aes_enc_round.vhd`, `src/aes_dec_round.vhd`
- `src/aes_encrypt_core.vhd`, `src/aes_decrypt_core.vhd`
- `src/aes_top.vhd`
- `tb/tb_aes_encrypt.vhd`, `tb/tb_aes_decrypt.vhd`

## NIST AES-256 KAT
- Key: `000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f`
- Plaintext: `00112233445566778899aabbccddeeff`
- Ciphertext: `8ea2b7ca516745bfeafc49904b496089`

## Simulate (ModelSim/Questa)
```
vlib work
vcom src/aes_pkg.vhd \
     src/aes_subbytes.vhd src/aes_inv_subbytes.vhd \
     src/aes_shiftrows.vhd src/aes_inv_shiftrows.vhd \
     src/aes_mixcolumns.vhd src/aes_inv_mixcolumns.vhd \
     src/aes_addroundkey.vhd src/aes_key_schedule_256.vhd \
     src/aes_enc_round.vhd src/aes_dec_round.vhd \
     src/aes_encrypt_core.vhd src/aes_decrypt_core.vhd \
     src/aes_top.vhd
vcom tb/tb_aes_encrypt.vhd
vsim -c tb_aes_encrypt -do "run -all; quit"
```
Repeat with `tb/tb_aes_decrypt.vhd` for decryption.

## Push to GitHub (example)
```
cd /workspace/aes_vhdl
# create repo on GitHub first, then:
git remote add origin https://github.com/<YOUR_USER>/<REPO>.git
git push -u origin main
```