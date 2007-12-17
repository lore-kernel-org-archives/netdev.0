From: Joe Perches <joe@perches.com>
Subject: [PATCH] net/core/: Spelling fixes
Date: Mon, 17 Dec 2007 11:40:29 -0800
Message-ID: <1197920439-5455-23-git-send-email-joe@perches.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:3217 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762894AbXLQTl0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Dec 2007 14:41:26 -0500
Message-Id: <5703e57f925f31fc0eb38873bd7f10fc44f99cb4.1197918894.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Joe Perches <joe@perches.com>
---
 net/core/dev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 26a3a3a..be9d301 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2819,7 +2819,7 @@ void dev_set_allmulti(struct net_device *dev, int inc)
 /*
  *	Upload unicast and multicast address lists to device and
  *	configure RX filtering. When the device doesn't support unicast
- *	filtering it is put in promiscous mode while unicast addresses
+ *	filtering it is put in promiscuous mode while unicast addresses
  *	are present.
  */
 void __dev_set_rx_mode(struct net_device *dev)
-- 
1.5.3.7.949.g2221a6

