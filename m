From: Yi Zou <yi.zou@intel.com>
Subject: [PATCH 1/3] net: add ETH_P_FCOE for Fibre Channel over Ethernet (FCoE)
Date: Mon, 06 Oct 2008 16:39:18 -0700
Message-ID: <20081006233918.4918.58918.stgit@zyfc9ini.jf.intel.com>
References: <20081006233409.4918.82298.stgit@zyfc9ini.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:20164 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753243AbYJFXmp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Oct 2008 19:42:45 -0400
In-Reply-To: <20081006233409.4918.82298.stgit@zyfc9ini.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yi Zou <yi.zou@intel.com>
---

 include/linux/if_ether.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/include/linux/if_ether.h b/include/linux/if_ether.h
index 723a1c5..e5ae72a 100644
--- a/include/linux/if_ether.h
+++ b/include/linux/if_ether.h
@@ -77,6 +77,7 @@
 #define ETH_P_PAE	0x888E		/* Port Access Entity (IEEE 802.1X) */
 #define ETH_P_AOE	0x88A2		/* ATA over Ethernet		*/
 #define ETH_P_TIPC	0x88CA		/* TIPC 			*/
+#define ETH_P_FCOE	0x8906		/* Fibre Channel over Ethernet	*/
 
 /*
  *	Non DIX types. Won't clash for 1500 types.

