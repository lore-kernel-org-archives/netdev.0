From: Yi Zou <yi.zou@intel.com>
Subject: [PATCH 1/3] net: add ETH_P_FCOE for Fibre Channel over Ethernet (FCoE)
Date: Mon, 17 Nov 2008 10:38:33 -0800
Message-ID: <20081117183833.15856.13396.stgit@zychongqing.jf.intel.com>
References: <20081117183539.15856.46809.stgit@zychongqing.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:48747 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751331AbYKQStJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2008 13:49:09 -0500
In-Reply-To: <20081117183539.15856.46809.stgit@zychongqing.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yi Zou <yi.zou@intel.com>
---

 include/linux/if_ether.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/include/linux/if_ether.h b/include/linux/if_ether.h
index 7f3c735..35f1110 100644
--- a/include/linux/if_ether.h
+++ b/include/linux/if_ether.h
@@ -78,6 +78,7 @@
 #define ETH_P_PAE	0x888E		/* Port Access Entity (IEEE 802.1X) */
 #define ETH_P_AOE	0x88A2		/* ATA over Ethernet		*/
 #define ETH_P_TIPC	0x88CA		/* TIPC 			*/
+#define ETH_P_FCOE	0x8906		/* Fibre Channel over Ethernet	*/
 #define ETH_P_EDSA	0xDADA		/* Ethertype DSA [ NOT AN OFFICIALLY REGISTERED ID ] */
 
 /*

