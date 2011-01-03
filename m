From: Michal Simek <monstr@monstr.eu>
Subject: [PATCH] trivial: Fix typo fault in netdevice.h
Date: Mon,  3 Jan 2011 09:54:09 +0100
Message-ID: <1294044849-10601-1-git-send-email-monstr@monstr.eu>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Michal Simek <monstr@monstr.eu>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Michal Simek <monstr@monstr.eu>
---
 include/linux/netdevice.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index d8fd2c2..c773bc8 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -683,7 +683,7 @@ struct netdev_rx_queue {
  *	   neither operation.
  *
  * void (*ndo_vlan_rx_register)(struct net_device *dev, struct vlan_group *grp);
- *	If device support VLAN receive accleration
+ *	If device support VLAN receive acceleration
  *	(ie. dev->features & NETIF_F_HW_VLAN_RX), then this function is called
  *	when vlan groups for the device changes.  Note: grp is NULL
  *	if no vlan's groups are being used.
-- 
1.5.5.6
