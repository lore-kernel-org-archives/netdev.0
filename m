From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] drivers/net/Kconfig: indentation fix
Date: Mon, 12 Dec 2005 02:35:36 +0100
Message-ID: <20051212013536.GG23349@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751006AbVLLBfs@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes a wrong indentation.


Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

This patch was already sent on:
- 19 Nov 2005

--- linux-2.6.15-rc1-mm2-full/drivers/net/Kconfig.old	2005-11-19 04:03:27.000000000 +0100
+++ linux-2.6.15-rc1-mm2-full/drivers/net/Kconfig	2005-11-19 04:03:38.000000000 +0100
@@ -129,7 +129,7 @@
 
 	  If you don't have this card, of course say N.
 
-	source "drivers/net/arcnet/Kconfig"
+source "drivers/net/arcnet/Kconfig"
 
 source "drivers/net/phy/Kconfig"
 
