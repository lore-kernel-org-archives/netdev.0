From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] drivers/net/Kconfig: indentation fix
Date: Sat, 19 Nov 2005 09:03:22 +0100
Message-ID: <20051119080322.GF16060@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750811AbVKSUdS@vger.kernel.org>
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes a wrong indentation.


Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.15-rc1-mm2-full/drivers/net/Kconfig.old	2005-11-19 04:03:27.000000000 +0100
+++ linux-2.6.15-rc1-mm2-full/drivers/net/Kconfig	2005-11-19 04:03:38.000000000 +0100
@@ -129,7 +129,7 @@
 
 	  If you don't have this card, of course say N.
 
-	source "drivers/net/arcnet/Kconfig"
+source "drivers/net/arcnet/Kconfig"
 
 source "drivers/net/phy/Kconfig"
 
