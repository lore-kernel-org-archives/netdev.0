From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH 3/7] net: mvneta: update MAINTAINERS file for the mvneta maintainers
Date: Mon, 12 Nov 2012 18:07:06 +0100
Message-ID: <1352740030-12801-4-git-send-email-thomas.petazzoni@free-electrons.com>
References: <1352740030-12801-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Lennert Buytenhek <kernel@wantstofly.org>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	Dmitri Epshtein <dima@marvell.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([88.190.12.23]:40093 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752774Ab2KLRIA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Nov 2012 12:08:00 -0500
In-Reply-To: <1352740030-12801-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 MAINTAINERS |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 59203e7..3010f1a 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4700,6 +4700,12 @@ S:	Maintained
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
