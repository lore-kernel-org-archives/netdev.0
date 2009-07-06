From: Guo-Fu Tseng <cooldavid@cooldavid.org>
Subject: [PATCH net-2.6 7/7] jme: Advance driver version number
Date: Mon, 6 Jul 2009 22:45:58 +0800
Message-ID: <20090706145548.E2FF45D0BF@cooldavid.org>
Cc: "netdev" <netdev@vger.kernel.org>,
	"Ethan Hsiao" <ethanhsiao@jmicron.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cooldavid.org ([220.133.139.86]:39377 "EHLO cooldavid.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754028AbZGFOzr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jul 2009 10:55:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Advance driver version number after modifications.

Signed-off-by: Guo-Fu Tseng <cooldavid@cooldavid.org>
---
 drivers/net/jme.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/jme.h b/drivers/net/jme.h
index db912f6..251abed 100644
--- a/drivers/net/jme.h
+++ b/drivers/net/jme.h
@@ -25,7 +25,7 @@
 #define __JME_H_INCLUDED__
 
 #define DRV_NAME	"jme"
-#define DRV_VERSION	"1.0.4"
+#define DRV_VERSION	"1.0.5"
 #define PFX		DRV_NAME ": "
 
 #define PCI_DEVICE_ID_JMICRON_JMC250	0x0250
-- 
1.6.0.6

