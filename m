From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: [PATCH 5/5] MAINTAINERS: fix IEEE 802.15.4 entry
Date: Thu, 18 Jun 2009 18:26:17 +0400
Message-ID: <1245335177-16810-6-git-send-email-dbaryshkov@gmail.com>
References: <1245335177-16810-1-git-send-email-dbaryshkov@gmail.com>
 <1245335177-16810-2-git-send-email-dbaryshkov@gmail.com>
 <1245335177-16810-3-git-send-email-dbaryshkov@gmail.com>
 <1245335177-16810-4-git-send-email-dbaryshkov@gmail.com>
 <1245335177-16810-5-git-send-email-dbaryshkov@gmail.com>
Cc: linux-kernel@vger.kernel.org, Sergey Lapin <slapin@ossfans.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f213.google.com ([209.85.218.213]:61805 "EHLO
	mail-bw0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761559AbZFRO0p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2009 10:26:45 -0400
In-Reply-To: <1245335177-16810-5-git-send-email-dbaryshkov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IEEE 802.15.4 git tree was moved from my private area to shared one.
Fix address accordingly.

Also note that our mailing list is moderated for non-subscribers.

Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
---
 MAINTAINERS |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 61c190a..b2158ae 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2824,9 +2824,9 @@ P:	Dmitry Eremin-Solenikov
 M:	dbaryshkov@gmail.com
 P:	Sergey Lapin
 M:	slapin@ossfans.org
-L:	linux-zigbee-devel@lists.sourceforge.net
+L:	linux-zigbee-devel@lists.sourceforge.net (moderated for non-subscribers)
 W:	http://apps.sourceforge.net/trac/linux-zigbee
-T:	git git://git.kernel.org/pub/scm/linux/kernel/git/lumag/lowpan.git
+T:	git git://git.kernel.org/pub/scm/linux/kernel/git/lowpan/lowpan.git
 S:	Maintained
 F:	net/ieee802154/
 F:	drivers/ieee801254/
-- 
1.6.3.1

