From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 25/41: Kconfig spelling fixes (trivial)
Date: Tue, 24 Mar 2009 15:03:40 +0100 (MET)
Message-ID: <20090324140336.31401.95313.sendpatchset@x2.localnet>
References: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34801 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758508AbZCXODm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 10:03:42 -0400
In-Reply-To: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 67c0d57930ff9a24c6c34abee1b01f7716a9b0e2
Author: Stephen Hemminger <sheminger@vyatta.com>
Date:   Mon Mar 16 15:17:23 2009 +0100

    netfilter: Kconfig spelling fixes (trivial)
    
    Signed-off-by: Stephen Hemminger <sheminger@vyatta.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/ipv4/netfilter/Kconfig b/net/ipv4/netfilter/Kconfig
index f8d6180..1833bdb 100644
--- a/net/ipv4/netfilter/Kconfig
+++ b/net/ipv4/netfilter/Kconfig
@@ -31,7 +31,7 @@ config NF_CONNTRACK_PROC_COMPAT
 	default y
 	help
 	  This option enables /proc and sysctl compatibility with the old
-	  layer 3 dependant connection tracking. This is needed to keep
+	  layer 3 dependent connection tracking. This is needed to keep
 	  old programs that have not been adapted to the new names working.
 
 	  If unsure, say Y.
@@ -99,7 +99,7 @@ config IP_NF_MATCH_TTL
 	---help---
 	This is a backwards-compat option for the user's convenience
 	(e.g. when running oldconfig). It selects
-	COFNIG_NETFILTER_XT_MATCH_HL.
+	CONFIG_NETFILTER_XT_MATCH_HL.
 
 # `filter', generic and specific targets
 config IP_NF_FILTER
@@ -329,7 +329,7 @@ config IP_NF_TARGET_TTL
 	---help---
 	This is a backwards-compat option for the user's convenience
 	(e.g. when running oldconfig). It selects
-	COFNIG_NETFILTER_XT_TARGET_HL.
+	CONFIG_NETFILTER_XT_TARGET_HL.
 
 # raw + specific targets
 config IP_NF_RAW
