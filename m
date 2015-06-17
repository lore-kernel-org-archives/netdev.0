From: Antonio Borneo <borneo.antonio@gmail.com>
Subject: [PATCH] net: via-rhine: remove unneeded include file
Date: Wed, 17 Jun 2015 19:41:22 +0800
Message-ID: <1434541282-9653-1-git-send-email-borneo.antonio@gmail.com>
Cc: Antonio Borneo <borneo.antonio@gmail.com>
To: Alexey Charkov <alchark@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:33012 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754756AbbFQLmS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2015 07:42:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Antonio Borneo <borneo.antonio@gmail.com>
---

 drivers/net/ethernet/via/via-rhine.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index de28504..a1aaf3a 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -96,7 +96,6 @@ static const int multicast_filter_limit = 32;
 #include <linux/ioport.h>
 #include <linux/interrupt.h>
 #include <linux/pci.h>
-#include <linux/of_address.h>
 #include <linux/of_device.h>
 #include <linux/of_irq.h>
 #include <linux/platform_device.h>
-- 
2.4.3
