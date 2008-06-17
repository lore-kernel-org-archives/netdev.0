From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH net-next 12/12]bnx2x: Update version
Date: Tue, 17 Jun 2008 11:38:30 +0300
Message-ID: <1213691910.5817.74.camel@lb-tlvb-eliezer>
References: <1213691644.5817.71.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Michael Chan" <mchan@broadcom.com>,
	"Jeff Garzik" <jeff@garzik.org>
To: netdev <netdev@vger.kernel.org>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2927 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753957AbYFQIik (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jun 2008 04:38:40 -0400
In-Reply-To: <1213691644.5817.71.camel@lb-tlvb-eliezer>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Re sending after fixing the subject to 12/12 instead of 12/13:

Updating to version 1.45.3

Signed-off-by: Eliezer Tamir <eliezert@broadcom.com>
Signed-off-by: Eilong Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 9c35b9c..f093174 100755
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -65,8 +65,8 @@
 #include "bnx2x.h"
 #include "bnx2x_init.h"
 
-#define DRV_MODULE_VERSION      "1.42.4"
-#define DRV_MODULE_RELDATE      "2008/4/9"
+#define DRV_MODULE_VERSION      "1.45.3"
+#define DRV_MODULE_RELDATE      "2008/6/1"
 #define BNX2X_BC_VER		0x040200
 
 /* Time in jiffies before concluding the transmitter is hung. */
-- 
1.5.5




