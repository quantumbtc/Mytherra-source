// Simple test program to verify RandomQ integration
#include <iostream>
#include <string>
#include <cstring>

// Include our RandomQ headers
#include "src/crypto/randomq.h"
#include "src/crypto/randomq_hash.h"
#include "src/crypto/randomq_mining.h"
#include "src/primitives/block.h"
#include "src/uint256.h"

int main() {
    std::cout << "Testing RandomQ Integration..." << std::endl;
    
    try {
        // Test 1: Basic RandomQ hashing
        std::cout << "Test 1: Basic RandomQ hashing..." << std::endl;
        CRandomQ randomq;
        randomq.SetRounds(100); // Use fewer rounds for testing
        
        const std::string test_data = "Hello, RandomQ!";
        randomq.Write(std::span<const unsigned char>(reinterpret_cast<const unsigned char*>(test_data.data()), test_data.size()));
        
        unsigned char hash[CRandomQ::OUTPUT_SIZE];
        randomq.Finalize(hash);
        
        // Verify hash is not all zeros
        bool all_zeros = true;
        for (int i = 0; i < CRandomQ::OUTPUT_SIZE; i++) {
            if (hash[i] != 0) {
                all_zeros = false;
                break;
            }
        }
        
        if (!all_zeros) {
            std::cout << "✓ Basic RandomQ hashing works!" << std::endl;
        } else {
            std::cout << "✗ Basic RandomQ hashing failed!" << std::endl;
            return 1;
        }
        
        // Test 2: RandomQ hash pipeline
        std::cout << "Test 2: RandomQ hash pipeline..." << std::endl;
        CRandomQHash hasher;
        hasher.SetRandomQRounds(100);
        
        const std::string test_data2 = "Test RandomQ Pipeline";
        hasher.Write(std::span<const unsigned char>(reinterpret_cast<const unsigned char*>(test_data2.data()), test_data2.size()));
        
        uint256 result;
        hasher.Finalize(std::span<unsigned char>(result.begin(), result.size()));
        
        if (!result.IsNull()) {
            std::cout << "✓ RandomQ hash pipeline works!" << std::endl;
        } else {
            std::cout << "✗ RandomQ hash pipeline failed!" << std::endl;
            return 1;
        }
        
        // Test 3: Block header hash
        std::cout << "Test 3: Block header hash..." << std::endl;
        CBlockHeader header;
        header.nVersion = 1;
        header.hashPrevBlock.SetNull();
        header.hashMerkleRoot.SetNull();
        header.nTime = 1234567890;
        header.nBits = 0x1d00ffff;
        header.nNonce = 12345;
        
        uint256 hash1 = header.GetHash();
        if (!hash1.IsNull()) {
            std::cout << "✓ Block header hash works!" << std::endl;
        } else {
            std::cout << "✗ Block header hash failed!" << std::endl;
            return 1;
        }
        
        // Test 4: Consistency test
        std::cout << "Test 4: Consistency test..." << std::endl;
        const std::string test_data3 = "Consistency Test Data";
        
        CRandomQHash hasher1, hasher2;
        hasher1.SetRandomQRounds(100);
        hasher2.SetRandomQRounds(100);
        
        hasher1.Write(std::span<const unsigned char>(reinterpret_cast<const unsigned char*>(test_data3.data()), test_data3.size()));
        hasher2.Write(std::span<const unsigned char>(reinterpret_cast<const unsigned char*>(test_data3.data()), test_data3.size()));
        
        uint256 result1, result2;
        hasher1.Finalize(std::span<unsigned char>(result1.begin(), result1.size()));
        hasher2.Finalize(std::span<unsigned char>(result2.begin(), result2.size()));
        
        if (result1 == result2) {
            std::cout << "✓ Consistency test passed!" << std::endl;
        } else {
            std::cout << "✗ Consistency test failed!" << std::endl;
            return 1;
        }
        
        std::cout << "\n🎉 All RandomQ integration tests passed!" << std::endl;
        std::cout << "RandomQ algorithm has been successfully integrated into Mytherra!" << std::endl;
        
    } catch (const std::exception& e) {
        std::cout << "✗ Test failed with exception: " << e.what() << std::endl;
        return 1;
    }
    
    return 0;
}
