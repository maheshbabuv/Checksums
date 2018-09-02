//
//  Hash.hpp
//  Crypt
//
//  Created by Mahesh B Vattigunta on 8/12/18.
//  Copyright © 2018 Mahesh B Vattigunta. All rights reserved.
//

#ifndef Hash_hpp
#define Hash_hpp

#include <string>
#include <map>

enum CheckSumType {
    SHA1 = 0,
    SHA256,
    MD5,
    CHECKSUM_TYPE_COUNT
};

typedef std::map<CheckSumType, std::string> CheckSumMap;

bool HashFile(const char* szFileName,
              CheckSumMap& rCheckSums);

std::string GetCheckSumTypeStr(CheckSumType eType);

#endif /* Hash_hpp */
