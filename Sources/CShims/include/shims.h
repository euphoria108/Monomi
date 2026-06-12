#ifndef MONOMI_CSHIMS_H
#define MONOMI_CSHIMS_H

// libproc / ルーティングソケット構造体は Darwin モジュールに含まれないため
// C ターゲット経由で Swift に公開する
#include <libproc.h>
#include <sys/socket.h>
#include <net/if.h>
#include <net/route.h>
#include <stdint.h>

// ---- AppleSMC ユーザークライアント ----
// SMCParamStruct のフィールド順・パディングが 1 バイトでもずれると
// kIOReturnBadArgument になるため、C 構造体として定義してレイアウトを保証する。
// （Apple PowerManagement ソース由来のレイアウト、80 バイト）

typedef struct {
    unsigned char  major;
    unsigned char  minor;
    unsigned char  build;
    unsigned char  reserved;
    unsigned short release;
} MNSMCVersion;

typedef struct {
    uint16_t version;
    uint16_t length;
    uint32_t cpuPLimit;
    uint32_t gpuPLimit;
    uint32_t memPLimit;
} MNSMCPLimitData;

typedef struct {
    uint32_t dataSize;
    uint32_t dataType;
    uint8_t  dataAttributes;
} MNSMCKeyInfoData;

typedef struct {
    uint32_t         key;
    MNSMCVersion     vers;
    MNSMCPLimitData  pLimitData;
    MNSMCKeyInfoData keyInfo;
    uint8_t          result;
    uint8_t          status;
    uint8_t          data8;
    uint32_t         data32;
    uint8_t          bytes[32];
} MNSMCParamStruct;

enum {
    kMNSMCHandleYPCEvent  = 2,  // IOConnectCallStructMethod のセレクタ
    kMNSMCReadKey         = 5,
    kMNSMCGetKeyFromIndex = 8,
    kMNSMCGetKeyInfo      = 9,
    kMNSMCKeyNotFound     = 132 // result コード
};

#endif /* MONOMI_CSHIMS_H */
