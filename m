From: Joe Perches <joe@perches.com>
Subject: [PATCH] MAINTAINERS: Add Q: patchwork entries for net/ and
 drivers/net/
Date: Sat, 24 Nov 2012 13:18:25 -0800
Message-ID: <1353791905.6558.7.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:53952 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752243Ab2KXVSW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 Nov 2012 16:18:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the netdev patchwork entries for networking drivers.
Change the W: entry to Q:for networking.

Signed-off-by: Joe Perches <joe@perches.com>
---
 MAINTAINERS |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index a9c794c..7549075 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5056,7 +5056,7 @@ NETWORKING [GENERAL]
 M:	"David S. Miller" <davem@davemloft.net>
 L:	netdev@vger.kernel.org
 W:	http://www.linuxfoundation.org/en/Net
-W:	http://patchwork.ozlabs.org/project/netdev/list/
+Q:	http://patchwork.ozlabs.org/project/netdev/list/
 T:	git git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git
 T:	git git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git
 S:	Maintained
@@ -5116,6 +5116,7 @@ F:	drivers/net/wireless/
 NETWORKING DRIVERS
 L:	netdev@vger.kernel.org
 W:	http://www.linuxfoundation.org/en/Net
+Q:	http://patchwork.ozlabs.org/project/netdev/list/
 T:	git git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git
 T:	git git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git
 S:	Odd Fixes
