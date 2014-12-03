From: Andrew Shewmaker <agshew@gmail.com>
Subject: [PATCH net] Update old iproute2 and Xen Remus links
Date: Wed,  3 Dec 2014 14:07:31 -0800
Message-ID: <1417644451-7305-1-git-send-email-agshew@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	corbet@lwn.net, jhs@mojatatu.com, davem@davemloft.net,
	Andrew Shewmaker <agshew@gmail.com>
To: linux-doc@vger.kernel.org
Return-path: <linux-doc-owner@vger.kernel.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Andrew Shewmaker <agshew@gmail.com>
---
 Documentation/Changes | 2 +-
 net/sched/Kconfig     | 7 ++++---
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/Documentation/Changes b/Documentation/Changes
index 1de131b..74bdda9 100644
--- a/Documentation/Changes
+++ b/Documentation/Changes
@@ -383,7 +383,7 @@ o  <http://www.iptables.org/downloads.html>
 
 Ip-route2
 ---------
-o  <ftp://ftp.tux.org/pub/net/ip-routing/iproute2-2.2.4-now-ss991023.tar.gz>
+o  <https://www.kernel.org/pub/linux/utils/net/iproute2/>
 
 OProfile
 --------
diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index a1a8e29..d17053d 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -22,8 +22,9 @@ menuconfig NET_SCHED
 	  This code is considered to be experimental.
 
 	  To administer these schedulers, you'll need the user-level utilities
-	  from the package iproute2+tc at <ftp://ftp.tux.org/pub/net/ip-routing/>.
-	  That package also contains some documentation; for more, check out
+	  from the package iproute2+tc at
+	  <https://www.kernel.org/pub/linux/utils/net/iproute2/>.  That package
+	  also contains some documentation; for more, check out
 	  <http://www.linuxfoundation.org/collaborate/workgroups/networking/iproute2>.
 
 	  This Quality of Service (QoS) support will enable you to use
@@ -336,7 +337,7 @@ config NET_SCH_PLUG
 	  of virtual machines by allowing the generated network output to be rolled
 	  back if needed.
 
-	  For more information, please refer to http://wiki.xensource.com/xenwiki/Remus
+	  For more information, please refer to <http://wiki.xenproject.org/wiki/Remus>
 
 	  Say Y here if you are using this kernel for Xen dom0 and
 	  want to protect Xen guests with Remus.
-- 
2.1.0

