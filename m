From: raj@tardy.cup.hp.com (Rick Jones)
Subject: [PATCH] net-next: minor cleanups for bonding documentation
Date: Fri, 20 Jul 2012 13:51:37 -0700 (PDT)
Message-ID: <20120720205137.84E3D290043B@tardy>
Cc: "Jay Vosburgh" <fubar@us.ibm.com>,
	"Andy Gospodarek" <andy@greyhouse.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:18575 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750711Ab2GTUvi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 16:51:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Jones <rick.jones2@hp.com>

The section titled "Configuring Bonding for Maximum Throughput" is
actually section twelve not thirteen, and there are a couple of words
spelled incorrectly.

Signed-off-by: Rick Jones <rick.jones2@hp.com>

---

diff --git a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
index bfea8a3..6b1c711 100644
--- a/Documentation/networking/bonding.txt
+++ b/Documentation/networking/bonding.txt
@@ -1210,7 +1210,7 @@ options, you may wish to use the "max_bonds" module parameter,
 documented above.
 
 	To create multiple bonding devices with differing options, it is
-preferrable to use bonding parameters exported by sysfs, documented in the
+preferable to use bonding parameters exported by sysfs, documented in the
 section below.
 
 	For versions of bonding without sysfs support, the only means to
@@ -1950,7 +1950,7 @@ access to fail over to.  Additionally, the bonding load balance modes
 support link monitoring of their members, so if individual links fail,
 the load will be rebalanced across the remaining devices.
 
-	See Section 13, "Configuring Bonding for Maximum Throughput"
+	See Section 12, "Configuring Bonding for Maximum Throughput"
 for information on configuring bonding with one peer device.
 
 11.2 High Availability in a Multiple Switch Topology
@@ -2620,7 +2620,7 @@ be found at:
 
 https://lists.sourceforge.net/lists/listinfo/bonding-devel
 
-	Discussions regarding the developpement of the bonding driver take place
+	Discussions regarding the development of the bonding driver take place
 on the main Linux network mailing list, hosted at vger.kernel.org. The list
 address is:
 
