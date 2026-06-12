#ifndef MONOMI_CSHIMS_H
#define MONOMI_CSHIMS_H

// libproc / ルーティングソケット構造体は Darwin モジュールに含まれないため
// C ターゲット経由で Swift に公開する
#include <libproc.h>
#include <sys/socket.h>
#include <net/if.h>
#include <net/route.h>

#endif /* MONOMI_CSHIMS_H */
