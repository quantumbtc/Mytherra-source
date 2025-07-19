#!/usr/bin/env python3
import hashlib
import ecdsa
import base58

def generate_keypair():
    # Erzeuge ein privates Schlüssel
    private_key = "5JCQDqPXGz1VCLwBSH8fJgF4JdQ7zHcF3NJGkWFdxNwLf4MNHfG"  # Bekannter Test-Schlüssel
    
    # Konvertiere zu Bytes
    private_key_bytes = base58.b58decode_check(private_key)[1:]  # Entferne Prefix
    print(f"Private Key (WIF): {private_key}")
    print(f"Private Key (hex): {private_key_bytes.hex()}")
    
    # Generiere öffentlichen Schlüssel
    sk = ecdsa.SigningKey.from_string(private_key_bytes, curve=ecdsa.SECP256k1)
    vk = sk.get_verifying_key()
    public_key_uncompressed = b'\x04' + vk.to_string()
    
    print(f"Public Key (uncompressed): {public_key_uncompressed.hex()}")
    
    return private_key, public_key_uncompressed.hex()

if __name__ == "__main__":
    generate_keypair()
