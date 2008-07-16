From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 10/10] mv643xx_eth: bump version to 1.2
Date: Wed, 16 Jul 2008 12:33:09 +0200
Message-ID: <20080716103309.GK8545@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:44745 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756710AbYGPKdK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2008 06:33:10 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 006ad45..433f560 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -55,7 +55,7 @@
 #include <asm/system.h>
 
 static char mv643xx_eth_driver_name[] = "mv643xx_eth";
-static char mv643xx_eth_driver_version[] = "1.1";
+static char mv643xx_eth_driver_version[] = "1.2";
 
 #define MV643XX_ETH_CHECKSUM_OFFLOAD_TX
 #define MV643XX_ETH_NAPI
-- 
1.5.3.4
