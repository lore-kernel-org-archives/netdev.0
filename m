From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
Subject: [PATCH net-next-2.6 2/2] jme: Advance driver version
Date: Mon, 14 Feb 2011 13:27:18 +0800
Message-ID: <1297661238-1467-2-git-send-email-cooldavid@cooldavid.org>
References: <1297661238-1467-1-git-send-email-cooldavid@cooldavid.org>
Cc: Guo-Fu Tseng <cooldavid@cooldavid.org>,
	"linux-netdev" <netdev@vger.kernel.org>,
	"Aries Lee" <arieslee@jmicron.com>,
	"Devinchiu" <devinchiu@jmicron.com>,
	"Ethan Hsiao" <ethanhsiao@jmicron.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cooldavid.org ([114.33.45.68]:39365 "EHLO cooldavid.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750703Ab1BNF1k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Feb 2011 00:27:40 -0500
In-Reply-To: <1297661238-1467-1-git-send-email-cooldavid@cooldavid.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guo-Fu Tseng <cooldavid@cooldavid.org>

Signed-off-by: Guo-Fu Tseng <cooldavid@cooldavid.org>
---
 drivers/net/jme.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/jme.h b/drivers/net/jme.h
index b7ae0c7..8bf3045 100644
--- a/drivers/net/jme.h
+++ b/drivers/net/jme.h
@@ -26,7 +26,7 @@
 #define __JME_H_INCLUDED__
 
 #define DRV_NAME	"jme"
-#define DRV_VERSION	"1.0.7"
+#define DRV_VERSION	"1.0.8"
 #define PFX		DRV_NAME ": "
 
 #define PCI_DEVICE_ID_JMICRON_JMC250	0x0250
-- 
1.7.2.2

