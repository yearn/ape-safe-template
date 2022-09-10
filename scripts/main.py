from ape_safe import ApeSafe

def main():
  gov = "0xbaC7c53f0d9Edcf2EFE81a2e546EA4CA54276355"
  safe = ApeSafe(gov)
  ovl = safe.contract("0xfa474A313BDBF69E287dbef667e2f626ea2574Df") # Must have a checksummed address
  ovl.mint("0xA600AdF7CB8C750482a828712849ee026446aA66", 1e18) # method takes (address,uint)
  print(safe.multisend)
  safe_tx = safe.multisend_from_receipts(safe_nonce=420)
  safe.preview(safe_tx)
  safe.post_transaction(safe_tx)