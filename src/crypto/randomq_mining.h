// Copyright (c) 2009-2010 Satoshi Nakamoto
// Copyright (c) 2009-2022 The Bitcoin Core developers
// Copyright (c) 2024-present The Bitquantum Core developers
// Distributed under the MIT software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

#ifndef MYTHERRA_CRYPTO_RANDOMQ_MINING_H
#define MYTHERRA_CRYPTO_RANDOMQ_MINING_H

#include <crypto/randomq_hash.h>
#include <primitives/block.h>
#include <uint256.h>
#include <arith_uint256.h>

/** RandomQ mining utilities */
namespace RandomQMining {

/** Check if a block hash meets the proof-of-work requirement */
bool CheckRandomQProofOfWork(const CBlockHeader& block, unsigned int nBits, const uint256& powLimit);

/** Find a valid nonce for RandomQ mining */
bool FindRandomQNonce(CBlockHeader& block, unsigned int nBits, const uint256& powLimit);

/** Calculate RandomQ hash for a block header */
uint256 CalculateRandomQHash(const CBlockHeader& block);

/** Optimized RandomQ hash calculation for mining */
uint256 CalculateRandomQHashOptimized(const CBlockHeader& block, uint32_t nonce);

} // namespace RandomQMining

#endif // MYTHERRA_CRYPTO_RANDOMQ_MINING_H
