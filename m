From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 09/39] mv643xx_eth: remove unused DESC_SIZE define
Date: Tue,  3 Jun 2008 13:02:24 +0200
Message-ID: <1212490974-23719-10-git-send-email-buytenh@wantstofly.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Cc: netdev@vger.kernel.org
To: Dale Farnsworth <dale@farnsworth.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:48758 "EHLO
	delta.wantstofly.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756378AbYFCMAp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 08:00:45 -0400
In-Reply-To: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 4b61acc..bdb03f3 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -153,8 +153,6 @@ static char mv643xx_driver_version[] = "1.0";
 #define PORT_DEFAULT_TRANSMIT_QUEUE_SIZE	800
 #define PORT_DEFAULT_RECEIVE_QUEUE_SIZE		400
 
-#define DESC_SIZE				64
-
 #define ETH_RX_QUEUES_ENABLED	(1 << 0)	/* use only Q0 for receive */
 #define ETH_TX_QUEUES_ENABLED	(1 << 0)	/* use only Q0 for transmit */
 
-- 
1.5.3.4

