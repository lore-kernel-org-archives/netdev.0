From: cooldavid@cooldavid.org
Subject: [PATCH net-2.6 3/3] jme: Advance driver version number
Date: Mon, 15 Mar 2010 13:15:08 +0800
Message-ID: <1268630108-10374-3-git-send-email-cooldavid@cooldavid.org>
References: <1268630108-10374-1-git-send-email-cooldavid@cooldavid.org>
 <1268630108-10374-2-git-send-email-cooldavid@cooldavid.org>
Cc: Guo-Fu Tseng <cooldavid@cooldavid.org>,
	"linux-netdev" <netdev@vger.kernel.org>,
	"Ethan Hsiao" <ethanhsiao@jmicron.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cooldavid.org ([114.33.45.68]:53307 "EHLO cooldavid.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932491Ab0COFVK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Mar 2010 01:21:10 -0400
In-Reply-To: <1268630108-10374-2-git-send-email-cooldavid@cooldavid.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guo-Fu Tseng <cooldavid@cooldavid.org>

Advance driver version number after some bug fix.

Signed-off-by: Guo-Fu Tseng <cooldavid@cooldavid.org>
---
 drivers/net/jme.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/jme.h b/drivers/net/jme.h
index 0ed4924..727a3bf 100644
--- a/drivers/net/jme.h
+++ b/drivers/net/jme.h
@@ -25,7 +25,7 @@
 #define __JME_H_INCLUDED__
 
 #define DRV_NAME	"jme"
-#define DRV_VERSION	"1.0.5"
+#define DRV_VERSION	"1.0.6"
 #define PFX		DRV_NAME ": "
 
 #define PCI_DEVICE_ID_JMICRON_JMC250	0x0250
-- 
1.6.4.4

