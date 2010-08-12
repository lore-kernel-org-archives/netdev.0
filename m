From: Jon Mason <jon.mason@exar.com>
Subject: [PATCH 2/2] s2io: Update driver version
Date: Thu, 12 Aug 2010 10:03:04 -0500
Message-ID: <1281625384-26927-2-git-send-email-jon.mason@exar.com>
Cc: netdev@vger.kernel.org, Ramkrishna Vepa <ramkrishna.vepa@exar.com>,
	Sivakumar Subramani <sivakumar.subramani@exar.com>,
	Sreenivasa Honnur <sreenivasa.honnur@exar.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:54700 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759790Ab0HLPCg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Aug 2010 11:02:36 -0400
Received: by pzk26 with SMTP id 26so463453pzk.19
        for <netdev@vger.kernel.org>; Thu, 12 Aug 2010 08:02:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update s2io driver's version to reflect the series of patches.

Signed-off-by: Jon Mason <jon.mason@exar.com>
---
 drivers/net/s2io.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 0124f12..5f062dd 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -90,7 +90,7 @@
 #include "s2io.h"
 #include "s2io-regs.h"
 
-#define DRV_VERSION "2.0.26.26"
+#define DRV_VERSION "2.0.26.27"
 
 /* S2io Driver name & version. */
 static char s2io_driver_name[] = "Neterion";
-- 
1.7.0.4

