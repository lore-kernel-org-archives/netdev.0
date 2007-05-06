From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH revised 11/11][TG3]: Update version and reldate.
Date: Sat, 05 May 2007 17:21:06 -0700
Message-ID: <1178410866.4859.52.camel@dell>
References: <20070504.194207.82054727.davem@davemloft.net>
 <1551EAE59135BE47B544934E30FC4FC0940105@nt-irva-0751.brcm.ad.broadcom.com>
 <20070504.204700.24899658.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, "netdev" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4435 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755324AbXEEXdp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 May 2007 19:33:45 -0400
In-Reply-To: <20070504.204700.24899658.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[TG3]: Update version and reldate.

Update version to 3.76.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 70b8c5e..184c275 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -64,8 +64,8 @@
 
 #define DRV_MODULE_NAME		"tg3"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"3.75"
-#define DRV_MODULE_RELDATE	"March 23, 2007"
+#define DRV_MODULE_VERSION	"3.76"
+#define DRV_MODULE_RELDATE	"May 5, 2007"
 
 #define TG3_DEF_MAC_MODE	0
 #define TG3_DEF_RX_MODE		0


