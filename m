From: Stefan Schmidt <stefan@osg.samsung.com>
Subject: [PATCH] MAINTAINERS: update git tree locations for ieee802154 subsystem
Date: Fri, 22 Sep 2017 14:28:46 +0200
Message-ID: <20170922122846.32377-1-stefan@osg.samsung.com>
Cc: Alexander Aring <aring@mojatatu.com>, netdev@vger.kernel.org,
        Stefan Schmidt <stefan@osg.samsung.com>
To: davem@davemloft.net, linux-wpan@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxima.lasnet.de ([78.47.171.185]:54970 "EHLO
        proxima.lasnet.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752086AbdIVMgN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2017 08:36:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patches for ieee802154 will go through my new trees towards netdev from
now on. The 6LoWPAN subsystem will stay as is (shared between ieee802154
and bluetooth) and go through the bluetooth tree as usual.

Signed-off-by: Stefan Schmidt <stefan@osg.samsung.com>
---
 MAINTAINERS | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 2281af4b41b6..fc7313daf4b0 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -6643,8 +6643,8 @@ M:	Alexander Aring <alex.aring@gmail.com>
 M:	Stefan Schmidt <stefan@osg.samsung.com>
 L:	linux-wpan@vger.kernel.org
 W:	http://wpan.cakelab.org/
-T:	git git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth.git
-T:	git git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth-next.git
+T:	git git://git.kernel.org/pub/scm/linux/kernel/git/sschmidt/wpan.git
+T:	git git://git.kernel.org/pub/scm/linux/kernel/git/sschmidt/wpan-next.git
 S:	Maintained
 F:	net/ieee802154/
 F:	net/mac802154/
-- 
2.13.5
