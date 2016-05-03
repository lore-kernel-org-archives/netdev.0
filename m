From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 02/15] MAINTAINERS: Add BATMAN ADVANCED documentation files
Date: Wed,  4 May 2016 06:23:37 +0800
Message-ID: <1462314230-16257-3-git-send-email-a__11490.9695265398$1462314294$gmane$org@unstable.cc>
References: <1462314230-16257-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:26060 "EHLO s2.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756745AbcECWY2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 May 2016 18:24:28 -0400
In-Reply-To: <1462314230-16257-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

The sysfs ABI documentation files and the batman-adv.txt are maintained by
the BATMAN ADVANCED maintainers and patches for them should therefore be
sent to them.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 MAINTAINERS | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 22688419873f..8f32094f6922 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2207,6 +2207,9 @@ L:	b.a.t.m.a.n@lists.open-mesh.org (moderated for non-subscribers)
 W:	https://www.open-mesh.org/
 Q:	https://patchwork.open-mesh.org/project/batman/list/
 S:	Maintained
+F:	Documentation/ABI/testing/sysfs-class-net-batman-adv
+F:	Documentation/ABI/testing/sysfs-class-net-mesh
+F:	Documentation/networking/batman-adv.txt
 F:	net/batman-adv/
 
 BAYCOM/HDLCDRV DRIVERS FOR AX.25
-- 
2.8.2
