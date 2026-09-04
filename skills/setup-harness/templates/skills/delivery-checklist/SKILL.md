---
name: delivery-checklist
description: Use when preparing client delivery in this folder — fill entregables/, write MANIFEST.md, run ./checks/delivery.sh; do not invent files that are not on disk.
---

# Delivery checklist

1. Ensure `entregables/` exists and holds the final files (not camera dumps).
2. Write `entregables/MANIFEST.md` listing each file and intended use.
3. Run `./checks/delivery.sh` until green.
4. Do not claim delivery is ready if the checker fails or the human has not
   opened the folder.
