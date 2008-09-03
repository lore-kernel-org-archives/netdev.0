From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 17/17] mv643xx_eth: bump version to 1.4
Date: Wed,  3 Sep 2008 14:29:44 +0200
Message-ID: <1220444984-20150-18-git-send-email-buytenh@wantstofly.org>
References: <1220444984-20150-1-git-send-email-buytenh@wantstofly.org>
Cc: Dale Farnsworth <dale@farnsworth.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:52905 "EHLO
	delta.wantstofly.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753093AbYICM3u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2008 08:29:50 -0400
In-Reply-To: <1220444984-20150-1-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index af69b77..c0ff2ee 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -55,7 +55,7 @@
 #include <asm/system.h>
 
 static char mv643xx_eth_driver_name[] = "mv643xx_eth";
-static char mv643xx_eth_driver_version[] = "1.3";
+static char mv643xx_eth_driver_version[] = "1.4";
 
 
 /*
-- 
1.5.6.4

