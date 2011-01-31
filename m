From: Sven Eckelmann <sven@narfation.org>
Subject: [PATCH 9/9] batman-adv: Merge README of v2011.0.0 release
Date: Mon, 31 Jan 2011 16:20:51 +0100
Message-ID: <1296487251-12552-10-git-send-email-sven@narfation.org>
References: <1296487251-12552-1-git-send-email-sven@narfation.org>
Cc: netdev@vger.kernel.org, Sven Eckelmann <sven@narfation.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:42665 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756029Ab1AaPVi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jan 2011 10:21:38 -0500
In-Reply-To: <1296487251-12552-1-git-send-email-sven@narfation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Sven Eckelmann <sven@narfation.org>
---
 Documentation/networking/batman-adv.txt |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/Documentation/networking/batman-adv.txt b/Documentation/networking/batman-adv.txt
index 77f0cdd..18afcd8 100644
--- a/Documentation/networking/batman-adv.txt
+++ b/Documentation/networking/batman-adv.txt
@@ -1,4 +1,4 @@
-[state: 21-11-2010]
+[state: 27-01-2011]
 
 BATMAN-ADV
 ----------
@@ -67,15 +67,16 @@ All  mesh  wide  settings  can be found in batman's own interface
 folder:
 
 #  ls  /sys/class/net/bat0/mesh/
-#  aggregated_ogms  bonding  fragmentation  orig_interval
-#  vis_mode
+#  aggregated_ogms  gw_bandwidth  hop_penalty
+#  bonding          gw_mode       orig_interval
+#  fragmentation    gw_sel_class  vis_mode
 
 
 There is a special folder for debugging informations:
 
 #  ls /sys/kernel/debug/batman_adv/bat0/
-#  originators  socket  transtable_global  transtable_local
-#  vis_data
+#  gateways     socket        transtable_global  vis_data
+#  originators  softif_neigh  transtable_local
 
 
 Some of the files contain all sort of status information  regard-
@@ -230,9 +231,8 @@ CONTACT
 Please send us comments, experiences, questions, anything :)
 
 IRC:            #batman   on   irc.freenode.org
-Mailing-list:   b.a.t.m.a.n@b.a.t.m.a.n@lists.open-mesh.org
-                (optional   subscription   at
-                 https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n)
+Mailing-list:   b.a.t.m.a.n@open-mesh.org (optional  subscription
+          at https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n)
 
 You can also contact the Authors:
 
-- 
1.7.2.3

