# This file is maintained automatically by "terraform init".
# Manual edits may be lost in future updates.

provider "registry.terraform.io/hashicorp/aws" {
  version     = "4.52.0"
  constraints = "4.52.0"
  hashes = [
    "h1:Gy4sFaLwPFCOKQMBz4GZUo+0AMxCMkmsPMwGFOQR2ew=",
    "zh:00e20643fbd18070e6c1c1bfb0d3fef6c9ebcaae86bbb5e1f1e736572182b288",
    "zh:0a5afeb70db935738cd058308a24888a0e32821d26cf39c6e35e58c51cb4e0eb",
    "zh:2a0823fb657b81c3901e61a93a3ae8c63e2e0e10c2e56159eae958e664cc1a70",
    "zh:33ef8bf74fbb392fc691899e0f1e5d3a72c0e1a0e1a9404fb3d44eb04b9b0b72",
    "zh:3d01e07e0e1ce08fc77254b02fcb2dc72e0ee55137bc41e1d7a5a3e2f00eca3a",
    "zh:4e2d6e16b8e6dbcc7e7c9c67d3a2e7e4d5f62b5e0f3e38aa6e0d9e3c8e0b4c5",
    "zh:56a2fb44a2c42153645490903b5f20e7e0e98be1b98d2fb13c132a91a4e6f5e3",
    "zh:6b2d2d0c3782e0f0b3a42f8e1a1a9d7e5b7c3f5e2d4c6a8b9e0f1a2b3c4d5e6",
    "zh:9b12af85486a96aedd8d7984b0ff811a4b42e3d88dad1a3fb4c0b580d04fa425",
    "zh:c9f3c5a0d3e8a7b6f5e4d3c2b1a0f9e8d7c6b5a4f3e2d1c0b9a8f7e6d5c4b3",
    "zh:d4f8e8a7b6c5d4e3f2a1b0c9d8e7f6a5b4c3d2e1f0a9b8c7d6e5f4a3b2c1d0",
  ]
}

provider "registry.terraform.io/hashicorp/random" {
  version     = "3.4.3"
  constraints = "3.4.3"
  hashes = [
    "h1:xZGZf18JjMS06pFa4NErzANI98qi59SEcBsOcS2P2yQ=",
    "zh:41c53ba47085d8261c0f1af3e608724afe38e3862b2e1656dba8e8c44e597640",
    "zh:59d98081c4475f2ad77d881c4412c5129c56214892f490adf11c7e7a5a47de9b",
    "zh:686ad1ee40b812b9e950fc1b00a04c4a27b6e10b8a65eb07d339d3eecfe8ddef",
    "zh:78d5eefdd9e494defcb3c68d282b8f96630502cac21d1ea161f53cfe9bb483b3",
    "zh:84103eae7251384c0d995f5a257c72b0096605048f757b749b7b62a4ec49a30d",
    "zh:8ee974b110adb78c56b0fc56c8ab3f24693ac0b3ea57e7b4c0036bbfc0f98fb3",
    "zh:9e3c5ae56e056aab3a25ff09d3519ca03a53f03c72023e91cfdb2e96a8eac0a4",
    "zh:ab47f6a2e20ed2cc1f8e5dea8b7b696bcea217b277f0ce15d99cfa0b9f1a4c53",
    "zh:b7f4aace0ca0dafa3c33fdde9cfe0a5b2e6be3b1faae3cf43283e2ba94a09fea",
    "zh:d8917e1e60512e9b2c6b0d7a68cdb93fc808b8bc199ae2d3f2ebee1d6c07a457",
    "zh:e38f71c6f2d15b6d8e8b5f16ddd0af0f0b03d4d3e7c2c5a8a8a97e7d5b6e1b2",
    "zh:f569b65999264a9416862bca5cd2a6177d94ccb0424f3a4ef424428f1c37c512",
  ]
}

# ──────────────────────────────────────────────────────────────────────────────
# ⚠️  PROVIDER INYECTADO (PoC Lockfile Poisoning)
# En un ataque real, este bloque se agregaría en un PR aparentemente inofensivo.
# Los hashes corresponden al provider malicioso compilado desde provider-poc/.
# ──────────────────────────────────────────────────────────────────────────────


provider "registry.terraform.io/demo/poisoned" {
  version     = "1.0.0"
  constraints = "1.0.0"
  hashes = [
    "h1:xiw7hKCi5+flxcNr69rD+ocIouw3QnzlC8Bvqo7LONk=",
    "zh:4bd4fa59bb8ffc3cff4672cd937ba96f481e1465b51b4f32bfe7d54c1e538b3a",
  ]
}

