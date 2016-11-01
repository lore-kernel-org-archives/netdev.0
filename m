From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH net-next] mlxsw: switchib: Remove unused including <generated/utsrelease.h>
Date: Tue,  1 Nov 2016 15:14:08 +0000
Message-ID: <1478013248-9409-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>, netdev@vger.kernel.org
To: Jiri Pirko <jiri@mellanox.com>, Ido Schimmel <idosch@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35401 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751000AbcKAP0b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 11:26:31 -0400
Received: by mail-pf0-f195.google.com with SMTP id i88so608715pfk.2
        for <netdev@vger.kernel.org>; Tue, 01 Nov 2016 08:26:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>

Remove including <generated/utsrelease.h> that don't need it.

Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
 drivers/net/ethernet/mellanox/mlxsw/switchib.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/switchib.c b/drivers/net/ethernet/mellanox/mlxsw/switchib.c
index ec0b27e..1552594 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/switchib.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/switchib.c
@@ -43,7 +43,6 @@
 #include <linux/skbuff.h>
 #include <linux/if_vlan.h>
 #include <net/switchdev.h>
-#include <generated/utsrelease.h>
 
 #include "pci.h"
 #include "core.h"
