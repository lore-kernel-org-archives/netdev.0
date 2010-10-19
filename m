From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
Subject: [PATCH net-next-2.6 5/5] jme: Advance version number
Date: Tue, 19 Oct 2010 08:10:44 +0800
Message-ID: <1287447044-24471-5-git-send-email-cooldavid@cooldavid.org>
References: <1287447044-24471-1-git-send-email-cooldavid@cooldavid.org>
Cc: Guo-Fu Tseng <cooldavid@cooldavid.org>,
	"linux-netdev" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cooldavid.org ([114.33.45.68]:49737 "EHLO cooldavid.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755465Ab0JSAU5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Oct 2010 20:20:57 -0400
In-Reply-To: <1287447044-24471-1-git-send-email-cooldavid@cooldavid.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guo-Fu Tseng <cooldavid@cooldavid.org>

Advance version number and update copyright info

Signed-off-by: Guo-Fu Tseng <cooldavid@cooldavid.org>
---
 drivers/net/jme.c |    1 +
 drivers/net/jme.h |    3 ++-
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/jme.c b/drivers/net/jme.c
index c34c70f..d7a975e 100644
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -3,6 +3,7 @@
  *
  * Copyright 2008 JMicron Technology Corporation
  * http://www.jmicron.com/
+ * Copyright (c) 2009 - 2010 Guo-Fu Tseng <cooldavid@cooldavid.org>
  *
  * Author: Guo-Fu Tseng <cooldavid@cooldavid.org>
  *
diff --git a/drivers/net/jme.h b/drivers/net/jme.h
index 1360f68..eac0926 100644
--- a/drivers/net/jme.h
+++ b/drivers/net/jme.h
@@ -3,6 +3,7 @@
  *
  * Copyright 2008 JMicron Technology Corporation
  * http://www.jmicron.com/
+ * Copyright (c) 2009 - 2010 Guo-Fu Tseng <cooldavid@cooldavid.org>
  *
  * Author: Guo-Fu Tseng <cooldavid@cooldavid.org>
  *
@@ -25,7 +26,7 @@
 #define __JME_H_INCLUDED__
 
 #define DRV_NAME	"jme"
-#define DRV_VERSION	"1.0.6"
+#define DRV_VERSION	"1.0.7"
 #define PFX		DRV_NAME ": "
 
 #define PCI_DEVICE_ID_JMICRON_JMC250	0x0250
-- 
1.7.2.2

