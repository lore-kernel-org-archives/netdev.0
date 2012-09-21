From: Marek Vasut <marex@denx.de>
Subject: [PATCH 3/3 RESEND] phy/micrel: Add missing header to micrel_phy.h
Date: Fri, 21 Sep 2012 04:52:56 +0200
Message-ID: <1348195976-31703-3-git-send-email-marex@denx.de>
References: <1348195976-31703-1-git-send-email-marex@denx.de>
Cc: Marek Vasut <marex@denx.de>,
	"David J. Choi" <david.choi@micrel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	Shawn Guo <shawn.guo@linaro.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:53602 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756980Ab2IUCxH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2012 22:53:07 -0400
In-Reply-To: <1348195976-31703-1-git-send-email-marex@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The license header was missing in micrel_phy.h . This patch adds
one.

Signed-off-by: Marek Vasut <marex@denx.de>
Cc: David J. Choi <david.choi@micrel.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Cc: Fabio Estevam <fabio.estevam@freescale.com>
Cc: Shawn Guo <shawn.guo@linaro.org>
---
 include/linux/micrel_phy.h |   12 ++++++++++++
 1 file changed, 12 insertions(+)

NOTE: I'd like to have ACK on this from the original author of
      the file, as this now says it's GPL2+.

diff --git a/include/linux/micrel_phy.h b/include/linux/micrel_phy.h
index d02355d..de20120 100644
--- a/include/linux/micrel_phy.h
+++ b/include/linux/micrel_phy.h
@@ -1,3 +1,15 @@
+/*
+ * include/linux/micrel_phy.h
+ *
+ * Micrel PHY IDs
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ *
+ */
+
 #ifndef _MICREL_PHY_H
 #define _MICREL_PHY_H
 
-- 
1.7.10.4
