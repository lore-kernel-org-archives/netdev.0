From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 01/15] MAINTAINERS: Mark BATMAN ADVANCED mailing list as moderated
Date: Wed,  4 May 2016 06:23:36 +0800
Message-ID: <1462314230-16257-2-git-send-email-a@unstable.cc>
References: <1462314230-16257-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:13446 "EHLO s2.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756519AbcECWY1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 May 2016 18:24:27 -0400
In-Reply-To: <1462314230-16257-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

The mailing list of b.a.t.m.a.n@lists.open-mesh.org is moderated for
non-subscribers and non-whitelisted addresses. Such mails will be delayed
but the sender will not be informed about the moderation.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 MAINTAINERS | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index ab008013cfec..22688419873f 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2203,7 +2203,7 @@ BATMAN ADVANCED
 M:	Marek Lindner <mareklindner@neomailbox.ch>
 M:	Simon Wunderlich <sw@simonwunderlich.de>
 M:	Antonio Quartulli <a@unstable.cc>
-L:	b.a.t.m.a.n@lists.open-mesh.org
+L:	b.a.t.m.a.n@lists.open-mesh.org (moderated for non-subscribers)
 W:	https://www.open-mesh.org/
 Q:	https://patchwork.open-mesh.org/project/batman/list/
 S:	Maintained
-- 
2.8.2
