From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 1/3] mlxsw: Remove duplicate included header
Date: Thu, 27 Aug 2015 17:59:55 +0200
Message-ID: <1440691197-25780-2-git-send-email-jiri@resnulli.us>
References: <1440691197-25780-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	ogerlitz@mellanox.com, Jiri Pirko <jiri@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:35557 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752010AbbH0QAD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 12:00:03 -0400
Received: by wicne3 with SMTP id ne3so79439475wic.0
        for <netdev@vger.kernel.org>; Thu, 27 Aug 2015 09:00:01 -0700 (PDT)
In-Reply-To: <1440691197-25780-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Signed-off-by: Elad Raz <eladr@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/core.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.c b/drivers/net/ethernet/mellanox/mlxsw/core.c
index 09325b7..0415ff6 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.c
@@ -48,7 +48,6 @@
 #include <linux/skbuff.h>
 #include <linux/etherdevice.h>
 #include <linux/types.h>
-#include <linux/wait.h>
 #include <linux/string.h>
 #include <linux/gfp.h>
 #include <linux/random.h>
-- 
1.9.3
