From: Yi Zou <yi.zou@intel.com>
Subject: [PATCH 1/7] net: add ETH_P_FCOE for Fibre Channel over Ethernet (FCoE)
Date: Thu, 19 Feb 2009 12:49:41 -0700
Message-ID: <20090219194941.22270.31691.stgit.yi.zou@intel.com>
References: <20090219194734.22270.8445.stgit@zychengdu.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: linux-scsi@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20090219194734.22270.8445.stgit@zychengdu.jf.intel.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This adds eth type ETH_P_FCOE for Fibre Channel over Ethernet (FCoE)

Signed-off-by: Yi Zou <yi.zou@intel.com>
---

 include/linux/if_ether.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/include/linux/if_ether.h b/include/linux/if_ether.h
index 7f3c735..59d197c 100644
--- a/include/linux/if_ether.h
+++ b/include/linux/if_ether.h
@@ -78,6 +78,7 @@
 #define ETH_P_PAE	0x888E		/* Port Access Entity (IEEE 802.1X) */
 #define ETH_P_AOE	0x88A2		/* ATA over Ethernet		*/
 #define ETH_P_TIPC	0x88CA		/* TIPC 			*/
+#define ETH_P_FCOE	0x8906		/* Fibre Channel over Ethernet  */
 #define ETH_P_EDSA	0xDADA		/* Ethertype DSA [ NOT AN OFFICIALLY REGISTERED ID ] */
 
 /*

