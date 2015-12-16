From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 02/12] Doc: update email address
Date: Wed, 16 Dec 2015 15:49:23 +0800
Message-ID: <1450252173-20949-3-git-send-email-antonio__18339.3832682215$1450252287$gmane$org@meshcoding.com>
References: <1450252173-20949-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:2100 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933692AbbLPHvI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Dec 2015 02:51:08 -0500
In-Reply-To: <1450252173-20949-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

My personal email address has changed. Update it in the doc files

Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 Documentation/ABI/testing/sysfs-class-net-mesh | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/Documentation/ABI/testing/sysfs-class-net-mesh b/Documentation/ABI/testing/sysfs-class-net-mesh
index c464062..c2b956d 100644
--- a/Documentation/ABI/testing/sysfs-class-net-mesh
+++ b/Documentation/ABI/testing/sysfs-class-net-mesh
@@ -8,7 +8,7 @@ Description:
 
 What:           /sys/class/net/<mesh_iface>/mesh/<vlan_subdir>/ap_isolation
 Date:           May 2011
-Contact:        Antonio Quartulli <antonio@meshcoding.com>
+Contact:        Antonio Quartulli <a@unstable.cc>
 Description:
                 Indicates whether the data traffic going from a
                 wireless client to another wireless client will be
@@ -70,7 +70,7 @@ Description:
 
 What:		/sys/class/net/<mesh_iface>/mesh/isolation_mark
 Date:		Nov 2013
-Contact:	Antonio Quartulli <antonio@meshcoding.com>
+Contact:	Antonio Quartulli <a@unstable.cc>
 Description:
 		Defines the isolation mark (and its bitmask) which
 		is used to classify clients as "isolated" by the
-- 
2.6.4
