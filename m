From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH net-next 11/12]bnx2x: Update version
Date: Tue, 27 May 2008 10:17:43 -0400
Message-ID: <1211897863.6967.84.camel@ubuntu804desktop.localdomain>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Eliezer Tamir" <eliezert@broadcom.com>
To: netdev <netdev@vger.kernel.org>, jeff@garzik.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1244 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756271AbYE0OSC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2008 10:18:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bnx2x: Update version

=EF=BB=BF=EF=BB=BFSigned-off-by: Eliezer Tamir <eliezert@broadcom.com>
Signed-off-by: Eilong Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 8c99fa6..2031953 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -72,8 +72,8 @@
 #include "bnx2x.h"
 #include "bnx2x_init.h"
=20
-#define DRV_MODULE_VERSION      "1.42.4"
-#define DRV_MODULE_RELDATE      "2008/4/9"
+#define DRV_MODULE_VERSION      "1.45.2"
+#define DRV_MODULE_RELDATE      "2008/5/27"
 #define BNX2X_BC_VER		0x040200
=20
 /* Time in jiffies before concluding the transmitter is hung. */
--=20
1.5.5




