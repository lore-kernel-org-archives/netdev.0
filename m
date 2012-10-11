From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH v2 2/4] net: mvneta: update MAINTAINERS file for the mvneta maintainers
Date: Thu, 11 Oct 2012 17:28:00 +0200
Message-ID: <1349969282-12676-3-git-send-email-thomas.petazzoni@free-electrons.com>
References: <1349969282-12676-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	Maen Suleiman <maen@marvell.com>
To: "David S. Miller" <davem@davemloft.net>,
	Lennert Buytenhek <kernel@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([88.190.12.23]:35236 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754776Ab2JKP2j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2012 11:28:39 -0400
In-Reply-To: <1349969282-12676-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 MAINTAINERS |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 9a6c4da..163533c 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4438,6 +4438,12 @@ S:	Maintained
 F:	drivers/net/ethernet/marvell/mv643xx_eth.*
 F:	include/linux/mv643xx.h
 
+MARVELL MVNETA ETHERNET DRIVER
+M:	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
+L:	netdev@vger.kernel.org
+S:	Maintained
+F:	drivers/net/ethernet/marvell/mvneta.*
+
 MARVELL MWIFIEX WIRELESS DRIVER
 M:	Bing Zhao <bzhao@marvell.com>
 L:	linux-wireless@vger.kernel.org
-- 
1.7.9.5
