From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 04/16] batman-adv: Drop invalid kerneldoc for variable batadv_vlan_attrs
Date: Wed,  3 Feb 2016 10:18:25 +0800
Message-ID: <1454465917-13332-5-git-send-email-a__21824.0454247736$1454467519$gmane$org@unstable.cc>
References: <1454465917-13332-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:14182 "EHLO s2.neomailbox.net"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754827AbcBCCpK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2016 21:45:10 -0500
In-Reply-To: <1454465917-13332-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/sysfs.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/batman-adv/sysfs.c b/net/batman-adv/sysfs.c
index fe87777fda8a..33772d9bd613 100644
--- a/net/batman-adv/sysfs.c
+++ b/net/batman-adv/sysfs.c
@@ -620,9 +620,7 @@ static struct batadv_attribute *batadv_mesh_attrs[] = {
 
 BATADV_ATTR_VLAN_BOOL(ap_isolation, S_IRUGO | S_IWUSR, NULL);
 
-/**
- * batadv_vlan_attrs - array of vlan specific sysfs attributes
- */
+/* array of vlan specific sysfs attributes */
 static struct batadv_attribute *batadv_vlan_attrs[] = {
 	&batadv_attr_vlan_ap_isolation,
 	NULL,
-- 
2.7.0
