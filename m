From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next] net: fix some typos in netif features
Date: Sat, 16 Mar 2013 22:47:55 +0800
Message-ID: <1363445275-3917-1-git-send-email-amwang@redhat.com>
Cc: Pravin B Shelar <pshelar@nicira.com>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4372 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755737Ab3CPOsN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 Mar 2013 10:48:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

Cc: Pravin B Shelar <pshelar@nicira.com>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>

---

diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
index f5e797c..d6ee2d0 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -102,8 +102,8 @@ enum {
 #define NETIF_F_VLAN_CHALLENGED	__NETIF_F(VLAN_CHALLENGED)
 #define NETIF_F_RXFCS		__NETIF_F(RXFCS)
 #define NETIF_F_RXALL		__NETIF_F(RXALL)
-#define NETIF_F_GRE_GSO		__NETIF_F(GSO_GRE)
-#define NETIF_F_UDP_TUNNEL	__NETIF_F(UDP_TUNNEL)
+#define NETIF_F_GSO_GRE		__NETIF_F(GSO_GRE)
+#define NETIF_F_GSO_UDP_TUNNEL	__NETIF_F(GSO_UDP_TUNNEL)
 
 /* Features valid for ethtool to change */
 /* = all defined minus driver/device-class-related */
