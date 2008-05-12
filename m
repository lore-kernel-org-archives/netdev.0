From: Bryan Wu <cooloney@kernel.org>
Subject: [PATCH 1/1] Blackfin EMAC Driver: Removed duplicated include <linux/ethtool.h> in drivers/net/bfin_mac.c.
Date: Mon, 12 May 2008 12:14:04 +0800
Message-ID: <1210565644-4272-1-git-send-email-cooloney@kernel.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Huang Weiyi <weiyi.huang@gmail.com>,
	Bryan Wu <cooloney@kernel.org>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nwd2mail10.analog.com ([137.71.25.55]:38926 "EHLO
	nwd2mail10.analog.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751225AbYELEOJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2008 00:14:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Huang Weiyi <weiyi.huang@gmail.com>

Signed-off-by: Huang Weiyi <weiyi.huang@gmail.com>
Signed-off-by: Bryan Wu <cooloney@kernel.org>
---
 drivers/net/bfin_mac.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index 89c0018..4144343 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -22,7 +22,6 @@
 #include <linux/crc32.h>
 #include <linux/device.h>
 #include <linux/spinlock.h>
-#include <linux/ethtool.h>
 #include <linux/mii.h>
 #include <linux/phy.h>
 #include <linux/netdevice.h>
-- 
1.5.5
