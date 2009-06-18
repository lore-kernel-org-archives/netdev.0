From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: [PATCH 2/2] MAINTAINERS: fix address of IEEE 802.15.4 git tree
Date: Thu, 18 Jun 2009 18:16:47 +0400
Message-ID: <1245334607-16046-3-git-send-email-dbaryshkov@gmail.com>
References: <1245334607-16046-1-git-send-email-dbaryshkov@gmail.com>
 <1245334607-16046-2-git-send-email-dbaryshkov@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	slapin@ossfans.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f213.google.com ([209.85.218.213]:59071 "EHLO
	mail-bw0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758019AbZFRORH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2009 10:17:07 -0400
In-Reply-To: <1245334607-16046-2-git-send-email-dbaryshkov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IEEE 802.15.4 git tree was moved from my private area to shared one.
Fix address accordingly.

Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
---
 MAINTAINERS |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 61c190a..e1cfb12 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2826,7 +2826,7 @@ P:	Sergey Lapin
 M:	slapin@ossfans.org
 L:	linux-zigbee-devel@lists.sourceforge.net
 W:	http://apps.sourceforge.net/trac/linux-zigbee
-T:	git git://git.kernel.org/pub/scm/linux/kernel/git/lumag/lowpan.git
+T:	git git://git.kernel.org/pub/scm/linux/kernel/git/lowpan/lowpan.git
 S:	Maintained
 F:	net/ieee802154/
 F:	drivers/ieee801254/
-- 
1.6.3.1

