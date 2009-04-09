From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH] net: Update maintainers
Date: Thu, 09 Apr 2009 16:47:41 +0100
Message-ID: <1239292061.3264.20.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:35567 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935452AbZDIPrp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2009 11:47:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Essentially all networking changes go through David Miller.
Jeff Garzik no longer handles device drivers separately.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
I think this reflects current reality...

Ben.

 MAINTAINERS |   12 +++---------
 1 files changed, 3 insertions(+), 9 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 01243ce..e4b40c1 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3158,18 +3158,12 @@ P:	Paul Clements
 M:	Paul.Clements@steeleye.com
 S:	Maintained
 
-NETWORK DEVICE DRIVERS
-P:	Jeff Garzik
-M:	jgarzik@pobox.com
-L:	netdev@vger.kernel.org
-T:	git kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git
-S:	Maintained
-
 NETWORKING [GENERAL]
-P:	Networking Team
-M:	netdev@vger.kernel.org
+P:	David S. Miller
+M:	davem@davemloft.net
 L:	netdev@vger.kernel.org
 W:	http://linux-net.osdl.org/
+T:	git kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git
 S:	Maintained
 
 NETWORKING [IPv4/IPv6]

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

