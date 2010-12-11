From: Jon Mason <jon.mason@exar.com>
Subject: [PATCH 3/4] s2io: Update Driver Version
Date: Fri, 10 Dec 2010 19:40:03 -0600
Message-ID: <1292031604-16628-3-git-send-email-jon.mason@exar.com>
References: <1292031604-16628-1-git-send-email-jon.mason@exar.com>
Cc: netdev@vger.kernel.org,
	Sivakumar Subramani <sivakumar.subramani@exar.com>,
	Sreenivasa Honnur <sreenivasa.honnur@exar.com>,
	Ram Vepa <ram.vepa@exar.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:51829 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753341Ab0LKBkW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 20:40:22 -0500
Received: by mail-gy0-f174.google.com with SMTP id 11so2143889gyb.19
        for <netdev@vger.kernel.org>; Fri, 10 Dec 2010 17:40:22 -0800 (PST)
In-Reply-To: <1292031604-16628-1-git-send-email-jon.mason@exar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update Driver Version

Signed-off-by: Jon Mason <jon.mason@exar.com>
---
 drivers/net/s2io.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 6a87b8c..80efc05 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -88,7 +88,7 @@
 #include "s2io.h"
 #include "s2io-regs.h"
 
-#define DRV_VERSION "2.0.26.27"
+#define DRV_VERSION "2.0.26.28"
 
 /* S2io Driver name & version. */
 static const char s2io_driver_name[] = "Neterion";
-- 
1.7.0.4

