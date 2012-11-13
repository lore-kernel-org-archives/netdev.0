From: Rami Rosen <ramirose@gmail.com>
Subject: [net-next patch] vxlan: fix a typo.
Date: Wed, 14 Nov 2012 01:29:15 +0200
Message-ID: <1352849355-5429-1-git-send-email-ramirose@gmail.com>
Cc: netdev@vger.kernel.org, shemminger@vyatta.com,
	Rami Rosen <ramirose@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:64552 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751333Ab2KMV3x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2012 16:29:53 -0500
Received: by mail-wi0-f178.google.com with SMTP id hm14so768289wib.1
        for <netdev@vger.kernel.org>; Tue, 13 Nov 2012 13:29:52 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use eXtensible and not eXtensiable in the comment on top.

Signed-off-by: Rami Rosen <ramirose@gmail.com>
---
 drivers/net/vxlan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 8aca888..3204208 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1,5 +1,5 @@
 /*
- * VXLAN: Virtual eXtensiable Local Area Network
+ * VXLAN: Virtual eXtensible Local Area Network
  *
  * Copyright (c) 2012 Vyatta Inc.
  *
-- 
1.7.11.7
