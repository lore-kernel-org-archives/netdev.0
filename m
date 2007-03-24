From: "Michael Chan" <mchan@broadcom.com>
Subject: [TG3 3/3]: Update version and reldate.
Date: Fri, 23 Mar 2007 16:13:19 -0800
Message-ID: <1174695199.4834.10.camel@dell>
References: <20070322204635.GA27152@strauss.suse.de>
 <1174601067.9753.42.camel@dell> <20070322232048.GC3333@sykes.suse.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, "Bernhard Walle" <bwalle@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4325 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934333AbXCWX3f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Mar 2007 19:29:35 -0400
In-Reply-To: <20070322232048.GC3333@sykes.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[TG3]: Update version and reldate.

Update version to 3.75.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 9aca100..e682f90 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -64,8 +64,8 @@
 
 #define DRV_MODULE_NAME		"tg3"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"3.74"
-#define DRV_MODULE_RELDATE	"February 20, 2007"
+#define DRV_MODULE_VERSION	"3.75"
+#define DRV_MODULE_RELDATE	"March 23, 2007"
 
 #define TG3_DEF_MAC_MODE	0
 #define TG3_DEF_RX_MODE		0


