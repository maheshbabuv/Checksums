//
//  Hash.cpp
//  Crypt
//
//  Created by Mahesh B Vattigunta on 8/12/18.
//  Copyright © 2018 Mahesh B Vattigunta. All rights reserved.
//

#include <sstream>
#include <fstream>
#include <iomanip>
#include "Hash.hpp"
#include "openssl/evp.h"

/*************************************************************************
 *
 * HashFile
 *
 * Description:
 *   Compute checksums of the file (SHA-1, SHA-256, MD5)
 *
 * Arguments:
 *   const char* szFileName  - Absolute path of the file
 *   CheckSumMap& rCheckSums - Map of checksum algorithm and its value
 *                             (SHA-1, SHA-256, MD5)
 *
 * Return value:
 *   true - if all checksums are computed successfully
 *   false - if failed to computed any checksum
 *
 *************************************************************************/
bool HashFile(const char* szFileName,
              CheckSumMap& rCheckSums)
{
    rCheckSums.clear();
    if (nullptr == szFileName)
    {
        return false;
    }
    
    // Step 1: Read the file content
    std::ifstream in(szFileName, std::ios::in | std::ios::binary);
    in.seekg(0, std::ios::end);
    
    size_t size = in.tellg();
    in.seekg(0, std::ios::beg);
    
    char* data = new char[size];
    in.read(data, size);
    
    // Step 2: Calculte hash
    bool bStatus = false;
    for (size_t i = 0; i < CHECKSUM_TYPE_COUNT; ++i)
    {
        // reset bStatus each time at the beginning of the loop
        bStatus = false;
        const EVP_MD *type = nullptr;
        switch (i)
        {
            case SHA1:
                type = EVP_sha1();
                break;
            case SHA256:
                type = EVP_sha256();
                break;
            case MD5:
                type = EVP_md5();
                break;
            default:
                continue;
        }

        unsigned char checkSum[EVP_MAX_MD_SIZE] = {0};
        unsigned int checkSumLen = 0;
        std::stringstream sstr;
        EVP_MD_CTX *mdctx = EVP_MD_CTX_create();
        if(NULL == mdctx)
        {
            goto graceful_exit;
        }
        
        if(1 != EVP_DigestInit_ex(mdctx, type, NULL))
        {
            goto graceful_exit;
        }
        
        if(1 != EVP_DigestUpdate(mdctx, data, size))
        {
            goto graceful_exit;
        }
        
        if(1 != EVP_DigestFinal_ex(mdctx, checkSum, &checkSumLen))
        {
            goto graceful_exit;
        }
        
        sstr.str("");
        sstr << std::hex << std::setfill('0');
        for (int i = 0; i < checkSumLen; ++i)
        {
            sstr << std::setw(2) << static_cast<unsigned>(checkSum[i]);
        }
        
        rCheckSums[static_cast<CheckSumType>(i)] = sstr.str();
        bStatus = true;
    
    graceful_exit:
        
        if (NULL != mdctx)
        {
            EVP_MD_CTX_destroy(mdctx);
            mdctx = NULL;
        }
        
        if (!bStatus)
        {
            rCheckSums.clear();
            break;
        }
    }
    
    if (NULL != data)
    {
        delete[] data;
        data = NULL;
    }

    return bStatus;
}

/*************************************************************************
 *
 * GetCheckSumTypeStr
 *
 * Description:
 *   Helper function which returns name of checksum string
 *
 * Arguments:
 *   CheckSumType eType  - ENUM of checksum type
 *
 * Return value:
 *   std::string - Name of the checksum string
 *
 *************************************************************************/
std::string GetCheckSumTypeStr(CheckSumType eType)
{
    switch(eType)
    {
        case SHA1:
            return "SHA1";
        case SHA256:
            return "SHA256";
        case MD5:
            return "MD5";
        default:
            return "";
    }
}

